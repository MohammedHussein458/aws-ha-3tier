# AWS High-Availability 3-Tier Architecture with Terraform & GitHub Actions

Infrastructure-as-Code project that provisions a highly available 3-tier architecture on AWS using **Terraform**, deployed through a **CI/CD pipeline on GitHub Actions** that authenticates to AWS with **OIDC** (no long-lived access keys).

## Highlights

- **Infrastructure as Code:** the whole environment is defined in Terraform, split into reusable modules and per-environment configurations.
- **CI/CD with GitHub Actions:** every change is validated and planned automatically, and applied only after a manual approval.
- **Keyless authentication:** GitHub Actions assumes an AWS IAM role through OpenID Connect (OIDC), so no AWS access keys are stored in GitHub.
- **Safe deployments:** the `apply` job is gated behind a protected GitHub Environment (`dev`) that requires a reviewer to approve.

## Project Structure

```
.
├── .github/
│   └── workflows/
│       └── terraform.yml     # CI/CD pipeline (plan + apply)
├── envs/                     # Per-environment configuration (e.g. dev)
├── modules/                  # Reusable Terraform modules
└── README.md
```

## CI/CD Pipeline

The workflow in `.github/workflows/terraform.yml` has two jobs:

| Job | What it does |
| --- | --- |
| `plan` | Checks out the code, authenticates to AWS via OIDC, installs Terraform, runs `terraform fmt -check`, `init`, `validate`, and `plan`. |
| `apply` | Runs only after `plan` succeeds and a reviewer approves the `dev` environment. Applies the reviewed plan. |

**Triggers**

- Automatically on pushes that change files under `envs/` or `modules/`.
- Manually from the Actions tab through `workflow_dispatch`.

## Authentication: GitHub Actions to AWS with OIDC

Instead of storing AWS access keys, the pipeline uses short-lived credentials:

1. An **OIDC identity provider** for `token.actions.githubusercontent.com` is created in AWS IAM.
2. An **IAM role** trusts that provider, restricted to this repository through the `sub` condition.
3. The workflow requests a token (`permissions: id-token: write`) and `aws-actions/configure-aws-credentials` exchanges it for temporary AWS credentials.

Example trust policy condition:

```json
"Condition": {
  "StringEquals": {
    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
  },
  "StringLike": {
    "token.actions.githubusercontent.com:sub": "repo:MohammedHussein458/aws-ha-3tier:*"
  }
}
```

## Getting Started (Local)

```bash
git clone https://github.com/MohammedHussein458/aws-ha-3tier.git
cd aws-ha-3tier/envs/dev

terraform init
terraform plan
terraform apply
```

Requirements: Terraform, AWS CLI configured with credentials, and an AWS account.

## Challenges and Lessons Learned

- **Workflow not appearing in Actions:** the folder must be named `.github/workflows` (plural). A singular `workflow` folder is silently ignored by GitHub.
- **No automatic run after pushing the workflow:** the pipeline only triggers on changes under `envs/` and `modules/`, so the first run was started manually with `workflow_dispatch`.
- **`Not authorized to perform sts:AssumeRoleWithWebIdentity`:** caused by a mismatch between the IAM role trust policy and the token's `sub` claim. When a job runs inside a GitHub Environment, the `sub` becomes `repo:<owner>/<repo>:environment:<name>` instead of `repo:<owner>/<repo>:ref:refs/heads/main`, so the trust policy must allow it.

## Tech Stack

Terraform, AWS (IAM, STS, OIDC), GitHub Actions.

## Author

**Mohammed Hussein**
GitHub: [MohammedHussein458](https://github.com/MohammedHussein458)
