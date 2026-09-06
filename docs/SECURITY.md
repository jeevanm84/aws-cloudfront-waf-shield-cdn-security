# Security design

This document covers the security design of the architecture itself. For reporting a vulnerability in this repository's own content or scripts, see the root [`SECURITY.md`](../SECURITY.md).

## Defense in depth, outside in

1. **AWS Shield Standard** — automatic, free, always on for any CloudFront distribution and Route 53 hosted zone. Absorbs common network and transport layer (L3/L4) DDoS patterns before they reach the edge.
2. **AWS Shield Advanced** (optional, subscription) — adds enhanced detection for larger and more sophisticated attacks, 24×7 access to the AWS DDoS Response Team, and cost protection so a scaling response to an attack doesn't produce a surprise bill.
3. **AWS WAF** — a Web ACL attached to the CloudFront distribution (or directly to an ALB/API Gateway) inspects every request's actual content. Rules used in this repository's labs:
   - AWS Managed Rules (baseline coverage for known attack signatures)
   - Rate-based rules (block a source IP once it exceeds a request threshold)
   - Geographic match rules
   - Custom rules on header, URI, and query-string values
4. **Origin Access Control (OAC)** — the S3 origin only accepts signed requests from the CloudFront distribution. A direct request to the bucket's public URL is refused (`403 Forbidden`), regardless of bucket policy misconfiguration elsewhere.
5. **ALB origin hardening** — HTTPS-only listener, a custom header CloudFront injects and the ALB (or an upstream rule) validates, security groups restricted to CloudFront's published IP ranges, and a certificate issued by AWS Certificate Manager.

## Hardening checklist

Use this after completing the labs to confirm nothing was left permissive:

- [ ] S3 bucket policy denies all principals except the CloudFront OAC service principal
- [ ] S3 bucket public access block is fully enabled
- [ ] ALB security group only permits inbound traffic from CloudFront's IP range or validates the custom origin header
- [ ] ALB listener redirects HTTP to HTTPS; no plaintext listener is left open
- [ ] ACM certificate is valid and covers the exact domain used
- [ ] WAF Web ACL is associated with the CloudFront distribution (not left in "count only" mode after testing)
- [ ] Rate-based WAF rule threshold is tuned against real traffic, not left at a default that either never triggers or triggers on legitimate use
- [ ] CloudWatch alarms exist for WAF blocked-request spikes and Shield event notifications
- [ ] No credentials, account IDs, or access keys are committed anywhere in this repository

## What this repository does not cover

- Multi-account AWS Organizations/Control Tower guardrails — out of scope here; see the wider `jeevanm84` portfolio's architecture-labs repository for that.
- Application-level authentication and authorization — WAF filters requests before they reach the app; it does not replace an application's own auth logic.
- Live DDoS testing — AWS's Acceptable Use Policy restricts unauthorized load/attack testing against AWS infrastructure. [`../labs/03-shield-ddos-simulation-safe.md`](../labs/03-shield-ddos-simulation-safe.md) reasons through Shield's coverage without generating actual attack traffic.
