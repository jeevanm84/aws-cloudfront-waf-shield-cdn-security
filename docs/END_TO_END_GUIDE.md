# End-to-end guide

This is the one path to follow start to finish. Everything else in the repository is reference material you can jump back to.

## 1. Read the architecture first

Start with [`ARCHITECTURE.md`](ARCHITECTURE.md). Don't skip this — every lab below assumes you understand cache hit vs. miss, TTL, and why Shield and WAF are separate layers.

## 2. Local-only pass (no AWS account required)

- Study the diagram in [`../diagrams/cloudfront-waf-shield-architecture.svg`](../diagrams/cloudfront-waf-shield-architecture.svg) until you can redraw the request flow from memory.
- Read [`../examples/terraform/main.tf`](../examples/terraform/main.tf) — a minimal, commented CloudFront + S3 + OAC + WAF skeleton — without applying it, to see how the pieces map to real resources.
- Work through the fundamentals section of [`INTERVIEW_QUESTIONS.md`](INTERVIEW_QUESTIONS.md).

## 3. Hands-on labs (requires an AWS account, small cost)

Each lab states its approximate cost and a matching cleanup command. Do them in order:

1. [`../labs/01-cloudfront-cache-hit-miss.md`](../labs/01-cloudfront-cache-hit-miss.md) — stand up CloudFront in front of S3, observe `X-Cache: Hit from cloudfront` vs. `Miss from cloudfront`, invalidate a path.
2. [`../labs/02-waf-block-sqli-xss.md`](../labs/02-waf-block-sqli-xss.md) — attach a Web ACL, enable AWS Managed Rules in count mode, review matches, then switch to block and confirm a malicious request is rejected.
3. [`../labs/03-shield-ddos-simulation-safe.md`](../labs/03-shield-ddos-simulation-safe.md) — no live attack traffic; reasons through what Shield Standard already covers and what Advanced would add, using AWS's own documented metrics and case studies.

## 4. Cleanup

Run the cleanup commands listed in each lab, then confirm with the master checklist in [`COST_AND_CLEANUP.md`](COST_AND_CLEANUP.md). Do not leave a CloudFront distribution or WAF Web ACL running after you're done studying it.

## 5. Consolidate

- Re-read [`SECURITY.md`](SECURITY.md) and check every item on the hardening checklist against what you just built.
- Attempt the intermediate-through-architect questions in [`INTERVIEW_QUESTIONS.md`](INTERVIEW_QUESTIONS.md) without looking at the architecture doc.
- If something didn't behave as expected during the labs, check [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) before assuming it's a mistake in your setup.

## Where this leads next

See [`ROADMAP.md`](ROADMAP.md) for how this repository connects to the rest of the `jeevanm84` portfolio.
