# Cost and cleanup

All figures are rough US-region estimates for light, personal-lab-scale usage as of publication and will drift — always check the AWS Pricing Calculator and your own billing console before and after each lab.

| Lab | What it provisions | Approximate cost if run for a few hours and cleaned up | Cleanup command/step |
|---|---|---|---|
| [`01-cloudfront-cache-hit-miss.md`](../labs/01-cloudfront-cache-hit-miss.md) | One CloudFront distribution, one S3 bucket | Well under $1 (CloudFront free tier covers most personal-lab data transfer; S3 storage for a few test objects is negligible) | Disable and delete the CloudFront distribution, then empty and delete the S3 bucket |
| [`02-waf-block-sqli-xss.md`](../labs/02-waf-block-sqli-xss.md) | One WAF Web ACL with managed + custom rules, associated with the distribution above | A few cents per hour for the Web ACL plus per-request charges at lab-scale traffic | Delete the Web ACL association, then delete the Web ACL |
| [`03-shield-ddos-simulation-safe.md`](../labs/03-shield-ddos-simulation-safe.md) | Nothing new — reasoning exercise only, no Shield Advanced subscription required | $0 | Nothing to clean up |

## Master cleanup checklist

Run through this after finishing the labs, even if you believe you already cleaned up each one individually:

- [ ] CloudFront distribution is deleted (not just disabled — disabling still allows re-enabling and doesn't fully stop all charges immediately)
- [ ] WAF Web ACL and any custom rule groups are deleted
- [ ] S3 bucket is emptied and deleted
- [ ] ACM certificate, if issued for a real domain, is deleted or left only if reused elsewhere
- [ ] Route 53 records created for this lab are removed
- [ ] AWS Budgets or a billing alarm is in place going forward, independent of this repository, as a safety net

## Cost-control defaults used in this repository's examples

- CloudFront price class is set to use only the edge locations needed for the regions being tested, not "all edge locations," to avoid unnecessary cost during learning.
- WAF rate-based rule thresholds are set high enough that normal lab testing doesn't generate excessive blocked-request logging costs.
- The Terraform example in [`../examples/terraform/`](../examples/terraform/) is never applied automatically by CI — every apply is a manual, deliberate action.
