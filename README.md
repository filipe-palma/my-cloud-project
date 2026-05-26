# My Cloud Project - Lab 11

## Project description
This lab project contains three Java microservices (order, product, and user) that are packaged as Docker images and built with GitHub Actions. Terraform provides a small AWS example (an S3 bucket), and GitHub Actions uses AWS OIDC to assume an IAM role without long-lived keys.

## Repository structure
- services/ - Maven-based Java microservices, each with a Dockerfile.
	- order-service/
	- product-service/
	- user-service/
- terraform/ - Terraform configuration for the AWS demo infrastructure.
- trust-policy.json - IAM trust policy for GitHub Actions OIDC.
- .github/workflows/ - CI/CD workflows.

## Workflow explanations
| Workflow | File | Triggers | What it does |
| --- | --- | --- | --- |
| Hello Actions | .github/workflows/hello.yml | push, manual | Prints GitHub context and lists repo files. |
| CI | .github/workflows/ci.yml | push to main, pull_request | Validates, compiles, and tests the product-service; uploads surefire reports. |
| Build & Push Image | .github/workflows/image.yml | push to main, manual | Builds the product-service JAR and pushes Docker images (latest + SHA). |
| Build All Services | .github/workflows/matrix.yml | push to main, manual | Builds and pushes all services as Docker images (SHA tag). |
| Release | .github/workflows/release.yml | tag v*, manual | Builds and pushes all services via the reusable workflow. |
| Reusable Image Build | .github/workflows/reusable-image.yml | workflow_call | Builds and pushes one service image (SHA tag). |
| Deploy to Production | .github/workflows/deploy-prod.yml | push to main, manual | Builds product-service image and runs a placeholder deploy step, then notifies Slack. |
| Terraform | .github/workflows/terraform.yml | push to main (terraform/**), pull_request (terraform/**) | Runs fmt/init/validate/plan; comments plan on PR; applies on main. |
| AWS OIDC Test | .github/workflows/aws-test.yml | manual | Assumes the AWS role and runs sts get-caller-identity. |

## Required GitHub Secrets
| Secret | Used by | Notes |
| --- | --- | --- |
| DOCKERHUB_USERNAME | image, matrix, release, reusable-image, deploy-prod | Docker Hub username. |
| DOCKERHUB_TOKEN | image, matrix, release, reusable-image, deploy-prod | Docker Hub access token. |
| AWS_ROLE_TO_ASSUME | terraform, aws-test | IAM role ARN for GitHub OIDC. |
| SLACK_WEBHOOK | deploy-prod | Incoming webhook for Slack notifications. |

## Required GitHub Variables
| Variable | Used by | Example |
| --- | --- | --- |
| AWS_REGION | terraform | eu-central-1 |

## How to trigger workflows
- Push to main: CI, Build & Push Image, Build All Services, Deploy to Production, Terraform (only if terraform/** changes).
- Pull request: CI, Terraform (only if terraform/** changes).
- Tag v*: Release (e.g., git tag v1.0.0; git push origin v1.0.0).
- Manual: Hello Actions, AWS OIDC Test, Build & Push Image, Build All Services, Release, Deploy to Production.

## Docker Hub repository information
Images are pushed to Docker Hub as:
- <DOCKERHUB_USERNAME>/product-service:latest (image.yml only)
- <DOCKERHUB_USERNAME>/product-service:<SHA>
- <DOCKERHUB_USERNAME>/user-service:<SHA>
- <DOCKERHUB_USERNAME>/order-service:<SHA>

Deploy to Production uses the SHA tag for product-service.

## Terraform usage instructions
Requirements:
- Terraform >= 1.9.0
- AWS credentials for local runs (or use the GitHub Actions OIDC workflow)

Common commands:
```bash
cd terraform
terraform fmt -check
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

Notes:
- The backend is local; state is stored on your machine.
- The configuration creates an S3 bucket named lab11-demo-<random> in the configured AWS region (default eu-central-1).

## AWS OIDC setup summary
1. Create an OIDC provider in IAM: token.actions.githubusercontent.com.
2. Create an IAM role with the trust policy from trust-policy.json.
	 - Update the repo in the StringLike condition if this repo name differs.
3. Attach the permissions the workflows need (for example, S3 access for the Terraform demo).
4. Set GitHub secret AWS_ROLE_TO_ASSUME to the role ARN.
5. Set GitHub variable AWS_REGION.
6. Run the AWS OIDC Test workflow to validate the setup.
