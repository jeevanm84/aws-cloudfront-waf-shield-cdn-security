# Troubleshooting

Each scenario follows: Incident → Symptoms → Impact → Investigation → Metrics → Logs → Commands → Root cause → Immediate mitigation → Permanent fix → Prevention → Lessons learned.

## Scenario 1 — Users still see the old version after deploy

- **Symptoms**: New content is live on the origin, but users report seeing stale content minutes or hours after deploy.
- **Impact**: Users act on outdated information; support tickets increase.
- **Investigation**: Check the response headers for the affected path.
- **Metrics**: CloudFront cache hit ratio for the affected path stays high right after deploy — a sign the edge is confidently serving a cached copy.
- **Logs**: CloudFront access logs show `Hit` for requests made after the deploy timestamp.
- **Commands**:
  ```bash
  curl -I https://your-distribution.cloudfront.net/path/to/asset
  # Look for: X-Cache: Hit from cloudfront
  ```
- **Root cause**: The cache behavior's TTL had not expired, and no invalidation was issued after deploy.
- **Immediate mitigation**: Issue a targeted invalidation for the affected path.
  ```bash
  aws cloudfront create-invalidation --distribution-id <ID> --paths "/path/to/asset*"
  ```
- **Permanent fix**: Move to versioned filenames (`app.v2.js`) for anything deployed frequently, reserving invalidation for emergencies.
- **Prevention**: Add an invalidation or cache-busting step to the deployment pipeline for any TTL'd path that doesn't use versioned filenames.
- **Lessons learned**: TTL is a promise to the cache, not a suggestion — plan around it rather than fighting it after the fact.

## Scenario 2 — Origin is still reachable directly, bypassing CloudFront

- **Symptoms**: A security scan or manual test shows the S3 bucket URL or ALB DNS name returns content directly, without going through the CloudFront distribution.
- **Impact**: WAF and Shield protections are bypassed entirely for anyone who finds the direct URL — this is a real exposure, not a cosmetic issue.
- **Investigation**: Check the S3 bucket policy and public access block settings; check the ALB security group's inbound rules.
- **Metrics**: N/A — this is a configuration audit, not a traffic pattern.
- **Logs**: S3 server access logs (if enabled) show direct GET requests with no CloudFront-specific headers.
- **Commands**:
  ```bash
  curl -I https://your-bucket.s3.amazonaws.com/path/to/asset
  # Should return 403 Forbidden if OAC is correctly enforced
  ```
- **Root cause**: Either the S3 bucket policy still allows public or wildcard read access, or the ALB security group allows inbound traffic from any source instead of only CloudFront's published ranges.
- **Immediate mitigation**: Tighten the S3 bucket policy to the OAC service principal only, and restrict the ALB security group to CloudFront's IP ranges or enforce the custom origin header check.
- **Permanent fix**: Add an automated policy check (for example, AWS Config or a scheduled script) that alerts if the bucket policy or security group drifts from the locked-down baseline.
- **Prevention**: Treat origin-locking as a required item in the [hardening checklist](SECURITY.md#hardening-checklist), not an optional hardening step done "later."
- **Lessons learned**: A CDN in front of an origin is not a security boundary by itself — the origin has to actively refuse everything that didn't come through the CDN.

## Scenario 3 — Legitimate traffic is being blocked by WAF

- **Symptoms**: Real users report `403 Forbidden` errors; support volume spikes after a WAF rule change.
- **Impact**: Legitimate users are locked out; if unresolved quickly, this looks identical to an outage from the user's perspective.
- **Investigation**: Check the WAF sampled requests for the affected time window and identify which rule matched.
- **Metrics**: A spike in `BlockedRequests` in CloudWatch for the Web ACL, correlated with the timing of a recent rule change.
- **Logs**: WAF logs (if enabled to a log destination) show the exact rule ID and matched request details.
- **Commands**:
  ```bash
  aws wafv2 get-sampled-requests \
    --web-acl-arn <ARN> --rule-metric-name <RULE_NAME> \
    --scope CLOUDFRONT --time-window StartTime=...,EndTime=... --max-items 50
  ```
- **Root cause**: A managed rule group or a custom rule was moved from "count" to "block" without first reviewing count-mode output against real traffic, and it has a false-positive match against legitimate request patterns.
- **Immediate mitigation**: Switch the specific rule back to "count" mode to restore access while investigating, or add a scoped exception for the affected request pattern.
- **Permanent fix**: Tune the rule (adjust sensitivity, add an exclusion) based on the sampled request data, then re-enable "block" mode.
- **Prevention**: Always run new or changed WAF rules in "count" mode against production-representative traffic for a defined observation period before switching to "block."
- **Lessons learned**: WAF rule changes deserve the same staged rollout discipline as application code changes — they can take down real traffic just as easily.
