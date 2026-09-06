# Lab 3 — AWS Shield: reasoning through coverage without live attack traffic

**Cost**: $0. This lab does not provision any new resources and does not generate attack traffic.

## Objective

Understand precisely what AWS Shield Standard already protects, without a Shield Advanced subscription, and identify the specific gap Advanced closes — grounded in AWS's own published documentation rather than a live (and policy-violating) DDoS test.

## Why this lab doesn't generate real attack traffic

AWS's Acceptable Use Policy prohibits unauthorized load or attack testing against AWS infrastructure, including your own resources, without going through AWS's formal simulated-event testing program. This lab is a structured reading and reasoning exercise instead.

## Prerequisites

- The CloudFront distribution from Lab 1 (Shield Standard is already protecting it — no setup required).
- Access to the AWS Shield console for your account.

## Steps

1. Open the **AWS Shield console** and confirm Shield Standard is listed as active for your CloudFront distribution and any Route 53 hosted zone you use — this is automatic, not something you opt into.
2. Read through AWS's current Shield Standard and Shield Advanced documentation to list, in your own words:
   - Which attack vectors Standard covers automatically.
   - What Advanced adds beyond Standard (detection scope, response team access, cost protection).
3. Estimate, for a hypothetical workload of your choosing, the point at which Advanced's subscription cost would be justified by the value of guaranteed DDoS Response Team access and cost protection.

## Expected observations

- Shield Standard requires no configuration and is already active on every CloudFront distribution and Route 53 hosted zone in the account.
- The differences between Standard and Advanced are about protection *scope and support*, not about "on vs. off" — Standard is never off.

## Verification

Write a short (3–5 sentence) justification, in your own words, for whether your hypothetical workload from step 3 would warrant Shield Advanced. There's no command-line check for this — the verification is whether you can defend the reasoning in an interview setting, which is the actual goal of this lab.

## Why this happens

DDoS protection is one of the few AWS security controls that's genuinely "on by default" — the interesting engineering decision is not whether to enable it, but whether the enhanced tier's cost is justified for a specific workload's risk profile.

## Cleanup

None required.

## Extension exercises

- Read a published AWS Shield Advanced case study and identify which specific attack vector it addressed that Standard would not have fully mitigated.
- Compare Shield Advanced's cost protection against your own workload's autoscaling configuration — would a real attack currently be capped, or could it scale your bill unpredictably?
