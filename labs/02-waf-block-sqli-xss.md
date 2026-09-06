# Lab 2 — AWS WAF: managed rules, rate limiting, and a safe block test

**Cost**: a few cents per hour while the Web ACL is attached, plus negligible per-request charges at lab scale. See [`../docs/COST_AND_CLEANUP.md`](../docs/COST_AND_CLEANUP.md).

## Objective

Attach a Web ACL to the CloudFront distribution from Lab 1, enable AWS Managed Rules in count mode, review what they would have matched, add a rate-based rule, then switch to block mode and confirm a deliberately malicious test request is rejected.

## Prerequisites

- Lab 1 completed, with a working CloudFront distribution.
- Permission to create WAF Web ACLs (`wafv2`) in the `us-east-1` region — required for CloudFront-scoped Web ACLs regardless of your distribution's origin region.

## Starting state

The distribution from Lab 1 has no Web ACL attached.

## Steps

1. **Create a Web ACL** scoped to CloudFront, in `us-east-1`.
2. **Add the AWS Managed Rules — Core rule set**, in **count mode** initially (not block).
3. **Generate representative traffic** — browse your test site normally for a period — so count mode has real data to compare against.
4. **Review sampled requests** for the Core rule set to confirm no legitimate traffic would have matched.
5. **Add a rate-based rule**: block a source IP that exceeds, for example, 100 requests in 5 minutes.
6. **Switch the Core rule set from count to block.**
7. **Associate the Web ACL with the CloudFront distribution.**

## Expected observations

- Normal browsing traffic passes through untouched.
- A deliberately malformed request is blocked.

## Verification

```bash
# Legitimate request — should succeed
curl -I https://<your-distribution-domain>.cloudfront.net/index.html

# Deliberately malicious test pattern — should be blocked once the Core rule set is in block mode
curl -I "https://<your-distribution-domain>.cloudfront.net/index.html?id=1' OR '1'='1"
# Expect: 403 Forbidden
```

```bash
aws wafv2 get-sampled-requests \
  --web-acl-arn <ARN> --rule-metric-name AWSManagedRulesCommonRuleSet \
  --scope CLOUDFRONT --time-window StartTime=<epoch>,EndTime=<epoch> --max-items 20
```

## Failure injection

Lower the rate-based rule's threshold to an unrealistically low value (for example, 5 requests in 5 minutes), then browse the site normally.

## Recovery

Notice your own legitimate browsing gets blocked — this reproduces [Troubleshooting Scenario 3](../docs/TROUBLESHOOTING.md#scenario-3--legitimate-traffic-is-being-blocked-by-waf) deliberately. Raise the threshold back to a realistic value based on your actual traffic pattern from step 3.

## Why this happens

A rate-based rule can't distinguish "one aggressive attacker" from "one enthusiastic legitimate user" without a sensible threshold informed by real traffic — this is exactly why step 3 (generate representative traffic before tuning) matters.

## Cleanup

```bash
aws wafv2 disassociate-web-acl --resource-arn <distribution-ARN>
aws wafv2 delete-web-acl --name <name> --scope CLOUDFRONT --id <id> --lock-token <token>
```

## Extension exercises

- Add a geographic match rule blocking a country you don't expect legitimate traffic from, and verify it with a VPN or a testing service.
- Add a custom rule that blocks requests with a suspicious `User-Agent` header value.
