#!/usr/bin/env bash
# Rebuild the web page and PDF from THE-HUMAN-CONDITION.md and publish to https://holmes.salo.cloud
# AWS resources (account 427077559838, us-east-1):
#   S3 bucket        holmes.salo.cloud  (private; read via CloudFront OAC E2SLH6PNEGGS22)
#   CloudFront       E2BP7JWT206J4A     (dek1yb6lqhacl.cloudfront.net)
#   ACM certificate  arn:aws:acm:us-east-1:427077559838:certificate/2a2493b4-4bba-44da-8a3c-7622e8d650e7
#   Route 53         zone Z02371983EMPX6RTY3MNV, A/AAAA alias holmes.salo.cloud -> CloudFront
set -euo pipefail
cd "$(dirname "$0")/.."
tools/build-pdf.sh
python3 -I tools/md2web.py THE-HUMAN-CONDITION.md site/index.html
cp THE-HUMAN-CONDITION.pdf site/
aws s3 cp site/index.html s3://holmes.salo.cloud/index.html --content-type "text/html; charset=utf-8" --cache-control "public, max-age=300" --only-show-errors
aws s3 cp site/THE-HUMAN-CONDITION.pdf s3://holmes.salo.cloud/THE-HUMAN-CONDITION.pdf --content-type application/pdf --cache-control "public, max-age=3600" --only-show-errors
aws cloudfront create-invalidation --distribution-id E2BP7JWT206J4A --paths "/*" --query 'Invalidation.Id' --output text
echo "published: https://holmes.salo.cloud"
