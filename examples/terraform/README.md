# Terraform example

A minimal, commented skeleton mapping the architecture in [`../../docs/ARCHITECTURE.md`](../../docs/ARCHITECTURE.md) to real Terraform resources: an S3 origin locked down with Origin Access Control, a WAF Web ACL with a managed rule set (in count mode by default) and a rate-based rule, and a CloudFront distribution tying them together.

This is meant to be **read first, applied deliberately**:

```bash
terraform init
terraform plan -var="bucket_name=<your-unique-bucket-name>"
# Review the plan output carefully before proceeding
terraform apply -var="bucket_name=<your-unique-bucket-name>"
```

Cost estimate and the matching `terraform destroy` cleanup step: see [`../../docs/COST_AND_CLEANUP.md`](../../docs/COST_AND_CLEANUP.md). CI in this repository runs `terraform fmt -check` and `terraform validate` only — it never runs `apply`.
