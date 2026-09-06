# Lab 1 — CloudFront cache hit vs. cache miss

**Cost**: well under $1 if completed and cleaned up within a few hours. See [`../docs/COST_AND_CLEANUP.md`](../docs/COST_AND_CLEANUP.md).

## Objective

Stand up a CloudFront distribution in front of a private S3 bucket, observe the difference between a cache hit and a cache miss in the response headers, and force a refresh with an invalidation.

## Prerequisites

- An AWS account with permission to create S3 buckets, CloudFront distributions, and Origin Access Control.
- AWS CLI configured locally.
- Basic familiarity with the AWS console or CLI.

## Starting state

No CloudFront distribution or dedicated S3 bucket for this lab exists yet.

## Steps

1. **Create a private S3 bucket** with public access fully blocked.
   ```bash
   aws s3 mb s3://<your-unique-bucket-name>
   aws s3api put-public-access-block --bucket <your-unique-bucket-name> \
     --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
   ```
2. **Upload a test object.**
   ```bash
   echo "hello from origin, version 1" > index.html
   aws s3 cp index.html s3://<your-unique-bucket-name>/index.html
   ```
3. **Create a CloudFront distribution** with the bucket as the origin and Origin Access Control enabled (console: CloudFront → Create distribution → Origin domain: your bucket → Origin access: Origin access control settings → Create new OAC). Attach the generated bucket policy the console offers you.
4. **Wait for deployment** (status changes from "Deploying" to "Enabled," typically a few minutes).

## Expected observations

- The first request to a given path is a **miss**; the CloudFront edge had nothing cached yet.
- A second request shortly after, from the same edge location, is a **hit**.

## Verification

```bash
curl -I https://<your-distribution-domain>.cloudfront.net/index.html
# First request:  X-Cache: Miss from cloudfront
# Second request: X-Cache: Hit from cloudfront

curl -I https://<your-bucket-name>.s3.amazonaws.com/index.html
# Should return 403 Forbidden — confirms OAC is enforced
```

## Failure injection

Update the object directly in S3, then request it again through CloudFront before the default TTL expires:

```bash
echo "hello from origin, version 2" > index.html
aws s3 cp index.html s3://<your-unique-bucket-name>/index.html
curl https://<your-distribution-domain>.cloudfront.net/index.html
# Still shows "version 1" — this is expected, not a bug
```

## Recovery

Force an immediate refresh with an invalidation:

```bash
aws cloudfront create-invalidation --distribution-id <ID> --paths "/index.html"
curl https://<your-distribution-domain>.cloudfront.net/index.html
# Now shows "version 2"
```

## Why this happens

CloudFront doesn't know the origin object changed until either the TTL expires and it re-validates, or you explicitly tell it to via invalidation. This is the exact mechanism behind [Troubleshooting Scenario 1](../docs/TROUBLESHOOTING.md#scenario-1--users-still-see-the-old-version-after-deploy).

## Cleanup

```bash
aws cloudfront delete-distribution --id <ID> --if-match <ETag>  # after disabling first
aws s3 rm s3://<your-unique-bucket-name> --recursive
aws s3 rb s3://<your-unique-bucket-name>
```

Confirm against the checklist in [`../docs/COST_AND_CLEANUP.md`](../docs/COST_AND_CLEANUP.md).

## Extension exercises

- Set a custom TTL on the cache behavior and time how long it takes for an update to appear without invalidation.
- Switch to versioned filenames (`index.v2.html`) and compare the operational overhead against invalidation.
