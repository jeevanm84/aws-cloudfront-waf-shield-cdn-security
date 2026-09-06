# Interview questions

Progression: Fundamentals → Intermediate → Advanced → Production → Senior Engineer → Architect/SRE scenarios. Each answer links back to working evidence in this repository rather than a memorized one-liner.

## Fundamentals

**Q: What is a CDN and why does it reduce latency?**
A CDN caches content at edge locations geographically close to users, so requests are served from a nearby location instead of a distant origin. See the cache-hit path in [`ARCHITECTURE.md`](ARCHITECTURE.md#request-flow) and reproduce it in [`labs/01-cloudfront-cache-hit-miss.md`](../labs/01-cloudfront-cache-hit-miss.md).

**Q: What's the difference between a cache hit and a cache miss?**
A hit means the edge already has a valid (within-TTL) copy and returns it without contacting the origin. A miss means the edge fetches from the origin, caches the result, and returns it — subsequent nearby requests then hit.

**Q: What does TTL control?**
How long an edge location trusts a cached object before re-validating with the origin. Configurable as minimum, default, and maximum per cache behavior.

## Intermediate

**Q: How do you force fresh content to appear immediately after a deploy, without waiting for TTL to expire?**
Issue a CloudFront invalidation for the affected path, or — preferably for frequent deploys — use versioned filenames so the old cached object is simply never requested again. See [Troubleshooting Scenario 1](TROUBLESHOOTING.md#scenario-1--users-still-see-the-old-version-after-deploy).

**Q: What's the difference between AWS Shield and AWS WAF, and why do you need both?**
Shield defends against network/transport-layer (L3/L4) volumetric attacks automatically. WAF inspects the actual application-layer (L7) request content for malicious patterns like SQL injection or excessive request rates from a single source. A large flood of well-formed HTTP requests will pass through Shield untouched but should be caught by a WAF rate-based rule.

**Q: How do you prevent someone from bypassing CloudFront and hitting your S3 bucket or ALB directly?**
Origin Access Control for S3 (the bucket policy only trusts the CloudFront service principal), and for an ALB: HTTPS-only, a custom origin header validated at the ALB, and security groups restricted to CloudFront's IP ranges. See [Troubleshooting Scenario 2](TROUBLESHOOTING.md#scenario-2--origin-is-still-reachable-directly-bypassing-cloudfront).

## Advanced

**Q: You just changed a WAF managed rule group from count to block and production traffic dropped. What's your first move?**
Pull sampled requests for the Web ACL and rule in question to see what's matching, then switch that specific rule back to count mode to restore traffic while you investigate — don't disable the whole Web ACL. See [Troubleshooting Scenario 3](TROUBLESHOOTING.md#scenario-3--legitimate-traffic-is-being-blocked-by-waf).

**Q: When would you choose Shield Advanced over Shield Standard?**
When the cost of extended downtime during a large or sophisticated DDoS event, or the value of guaranteed access to AWS's DDoS Response Team and cost protection against attack-driven autoscaling, clearly outweighs the subscription cost — typically for large-scale, revenue-critical, internet-facing applications.

**Q: How would you rate-limit a specific API path more aggressively than the rest of your site, without a separate distribution?**
Use a WAF rate-based rule scoped to that URI path via a custom rule statement, rather than a single global threshold across the whole Web ACL.

## Production and senior engineer

**Q: A customer reports intermittent 403s only from one country. Walk me through your investigation.**
Check whether a WAF geographic match rule is scoped to that country, check sampled requests for the exact rule that matched, and confirm whether it's an intentional restriction or an overly broad geo-block rule catching legitimate users — echoes [Troubleshooting Scenario 3](TROUBLESHOOTING.md#scenario-3--legitimate-traffic-is-being-blocked-by-waf) with a geographic instead of pattern-based trigger.

**Q: How do you keep CloudFront, WAF, and origin security configuration from drifting out of a known-good state over time?**
Manage the distribution, Web ACL, and origin policies as code (Terraform, as sketched in [`examples/terraform/`](../examples/terraform/)) so changes are reviewed, and pair that with a periodic automated check (AWS Config or a scheduled script) against the [hardening checklist](SECURITY.md#hardening-checklist).

## Architect/SRE scenarios

**Q: Design the edge and security layer for a global e-commerce site with a single AWS origin region. Walk through your reasoning.**
Start from the requirements (global users, mixed static/dynamic content, must survive both volumetric and application-layer attacks), then justify each layer: CloudFront for latency and origin offload, Shield Standard as the automatic baseline, WAF for L7 filtering with a mix of managed and custom rules, and OAC/ALB hardening so the origin has no unprotected path. This mirrors the full flow documented in [`ARCHITECTURE.md`](ARCHITECTURE.md).

**Q: How would this design change if the application also served real-time, personalized (non-cacheable) content?**
Route personalized paths through a cache behavior with TTL set to zero or near-zero (or bypass caching entirely for that behavior) while leaving static assets on long TTLs — CloudFront cache behaviors are configured per path pattern, so both can coexist behind one distribution.
