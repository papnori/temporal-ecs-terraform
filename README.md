# Temporal on AWS ECS with Terraform 🚀

[![Terraform](https://img.shields.io/badge/Terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/Amazon_AWS-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)](https://aws.amazon.com/)
[![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)](https://www.python.org/)

> **Production-ready infrastructure for deploying Temporal workers on AWS ECS Fargate — fully automated, cost-efficient, and scalable.**

Deploy auto-scaling Temporal workers on AWS ECS with Terraform. This repository provides a complete, production-ready setup that reduces infrastructure costs by ~70% compared to Kubernetes while maintaining elasticity, resilience, and reliability. 💪

---

## ✨ Features

- 🏗️ **Infrastructure as Code** — Complete Terraform modules for VPC, ECS, auto-scaling, and monitoring
- 🔐 **Security First** — Workers in private subnets, secrets from AWS Secrets Manager, OIDC authentication
- 💰 **Cost Optimized** — Fargate Spot instances with intelligent fallback to on-demand
- 📈 **Auto-Scaling** — CloudWatch-driven scaling based on CPU utilization
- 🚀 **CI/CD Ready** — GitHub Actions workflows for automated builds and deployments
- 🔄 **Production Ready** — Remote state management, modular design, multi-environment support

---

## 🏗️ Architecture

<div style="text-align: center;">
<img alt="Architecture Diagram" src="images/architecture.svg"/>
</div>

### Key Components

- **VPC & Networking** — Isolated network with public/private subnets across multiple AZs
- **ECS Fargate** — Serverless container execution with Spot and On-Demand capacity
- **Auto-Scaling** — CPU-based scaling policies with CloudWatch alarms
- **ECR** — Private container registry with lifecycle policies
- **Secrets Manager** — Secure credential storage and injection
- **CloudWatch** — Centralized logging and monitoring

---

## 📋 Prerequisites

Before you begin, ensure you have:

- 🧠 **Temporal Cloud account** *or* **Self-hosted Temporal Server**
- ☁️ **AWS Account** with `AdministratorAccess` permissions
- 🐍 **Python 3.12** or higher
- 📦 **Terraform** >= 1.13.3
- 🐙 **GitHub Account** (for CI/CD automation)

---

## 📚 Full Tutorial

For a comprehensive, step-by-step guide with detailed explanations, screenshots, and architectural deep-dives, check out the complete blog post:

📖 **[Deploying Temporal on AWS ECS with Terraform - Complete Guide](https://papnori.github.io/posts/temporal-ecs-terraform/)**

The tutorial covers:
- 🏗️ Detailed architecture explanations
- 🔐 Security best practices
- 💰 Cost optimization strategies
- 📈 Advanced scaling configurations
- 🚀 CI/CD pipeline setup
- 🐛 Common pitfalls and solutions

---


## 🚀 Quick Start

### 0. Set Up Local Environment (Optional)

For local development and testing, create a `.env` file from the template:

```bash
cp .sample_env .env
```

Edit `.env` with your Temporal configuration:

```bash
TEMPORAL_NAMESPACE=default
TEMPORAL_SERVER_ENDPOINT=localhost  # or your ngrok URL
TEMPORAL_SERVER_PORT=7233
TEMPORAL_API_KEY=                   # Leave empty for local/self-hosted
```

> [!IMPORTANT]
> The `.env` file is gitignored and should never be committed. Use it for local development only.
> For production deployments, credentials are managed via AWS Secrets Manager (see step 1 below).

---

### 1. 🤫 Store Temporal Credentials

Create a secret in **AWS Secrets Manager** (e.g., `dev/sample-config`) with your Temporal connection details:

```json
{
  "TEMPORAL_NAMESPACE": "default",
  "TEMPORAL_SERVER_ENDPOINT": "temporal.cluster-xxxx.us-east-1.aws.cloud.temporal.io",
  "TEMPORAL_SERVER_PORT": "7233",
  "TEMPORAL_API_KEY": "ey..."
}
```

> [!TIP]
> See [local temporal server](local-temporal-server/) directory for instructions on running a local Temporal server. 
> If you don't have Temporal Cloud.

> [!NOTE]
> Omit `TEMPORAL_API_KEY` if using a self-hosted Temporal Server.

### 2. 👢 Bootstrap S3 Backend

```bash
cd terraform/bootstrap/

# Comment out the backend "s3" {} block in providers.tf
terraform init
terraform apply

# Uncomment the backend block
terraform init -reconfigure
```

### 3. 🚢 Create ECR Repository

```bash
cd terraform/global/ecr/
terraform init
terraform apply
```

### 4. 🫸 Build & Push Docker Image

```bash
# Build the image
docker build -t temporal-worker-dev:latest .

# Authenticate with ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin <AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com

# Tag and push
docker tag temporal-worker-dev:latest <AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/temporal-worker-dev:latest

docker push <AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/temporal-worker-dev:latest
```

### 5. 🚀 Deploy Infrastructure

```bash
cd terraform/live/dev/

# Update terraform.tfvars with your values
terraform init
terraform plan
terraform apply
```

---

## 📁 Project Structure

```
temporal-ecs-terraform/
├── .github/
│   └── workflows/                          # GitHub Actions workflows for CI/CD
│       ├── build-and-publish-ecr-dev.yaml  # Builds Docker image & pushes to ECR
│       └── terraform-live-dev-deploy.yaml  # Deploys Terraform infra on AWS
│
├── activities/                             # Temporal activity definitions
│   └── sample_activity.py                  # Example activity (business logic step)
│
├── schemas/                                # Data models / payload definitions
│   └── sample_schema.py                    # Example Python dataclass schema for workflow input
│
├── terraform/
│   ├── bootstrap/                          # Initial setup (S3 bucket for state files)
│   ├── global/
│   │   └── ecr/                            # Container registry
│   │
│   ├── live/                               # Environment-specific Terraform configs
│   │   └── dev/
│   │       ├── main.tf                     # Root Terraform configuration
│   │       ├── outputs.tf                  # Useful Terraform outputs
│   │       ├── providers.tf                # Provider configuration (AWS, etc.)
│   │       ├── terraform.tfvars            # Environment-specific variable values
│   │       └── variables.tf                # Input variables
│   │
│   └── modules/                            # Reusable infrastructure modules
│       ├── network/                        # VPC, subnets, NAT
│       ├── ecs_cluster/                    # ECS cluster definition
│       └── ecs_service/                    # Worker service & auto-scaling
│
├── workflows/                              # Temporal workflows (orchestration logic)
│   └── sample_workflow.py                  # Example workflow using the sample activity
│
├── .sample_env                             # Sample environment variable template
├── Dockerfile                              # Container definition for the Temporal worker
├── config.py                               # Application configuration
├── Pipfile                                 # Python dependencies (Pipenv format)
├── Pipfile.lock                            # Locked dependency versions
├── README.md                               # Project documentation
├── run_worker.py                           # Runs a Temporal worker
└── run_workflow.py                         # Starts a sample workflow for testing
```

---

## ⚙️ Configuration

### Environment Variables

The following variables are configured in `terraform/live/dev/terraform.tfvars`:

| Variable                 | Description          | Default           |
|--------------------------|----------------------|-------------------|
| `vpc_cidr`               | CIDR block for VPC   | `10.0.0.0/16`     |
| `worker_cpu`             | CPU of the worker    | `1024`            |
| `worker_memory`          | Memory of the worker | `2048`            |
| `worker_container_image` | ECR image URI        | *from ECR output* |

### Auto-Scaling Configuration

- **Scale-Out:** CPU > 30% for 1 minute → Add 1-2 tasks
- **Scale-In:** CPU < 20% for 10 minutes → Remove 1 task
- **Cooldown:** 60s (scale-out), 300s (scale-in)

You may adjust thresholds in `terraform/live/dev/main.tf`.

---

## 🔄 CI/CD Automation

### GitHub Actions Workflows

1. **Build & Push to ECR (Dev)** — Builds Docker image and pushes to ECR
   - Triggers: Push to `main` or manual dispatch
   - Output: Tagged image with commit SHA

2. **Deploy to Dev** — Applies Terraform changes
   - Triggers: After successful build or Terraform file changes
   - Steps: Init → Plan → Apply → Verify ECS stability

### Setup Instructions

1. Configure AWS OIDC (see [detailed guide](https://papnori.github.io/posts/temporal-ecs-terraform/))
2. Add GitHub secrets:
   - `AWS_GITHUB_ACTIONS_ROLE_ARN`
3. Add repository variables:
   - `AWS_ACCOUNT_ID`
4. Add environment variables (environment: `dev`):
   - `WORKFLOW_ECR_REPO`
   - `S3_DATA_BUCKET_NAME`

---

## 🧪 Testing

Run a sample workflow to verify the setup:

```bash
python run_workflow.py
```

> [!NOTE]
> The `run_workflow.py` script reads configuration from your `.env` file for local testing.
> Make sure you've set up your `.env` file with the correct Temporal endpoint (see [Step 0](#0-set-up-local-environment-optional)).

Or trigger via Temporal Cloud UI:
- **Task Queue:** `test-queue`
- **Workflow Type:** `MessageWorkflow`
- **Input:** `{"message": "🌸 Hello, World!"}`

---

## 📊 Monitoring

### CloudWatch Dashboards

Access ECS metrics in the AWS Console:
- **ECS Console** → **Clusters** → `sample-dev-cluster`
- View running tasks, CPU/memory usage, and scaling events

### Logs

Worker logs are automatically shipped to CloudWatch Logs:
- **Log Group:** `/ecs/sample-dev-cluster/sample-temporal-worker`
- **Retention:** 7 days (configurable)

---

## 💰 Cost Optimization

This setup prioritizes cost efficiency:

- ✅ **Fargate Spot** — Up to 70% cheaper than on-demand
- ✅ **Single NAT Gateway** — Shared across AZs (dev/staging)
- ✅ **S3 Gateway Endpoint** — No data transfer costs for S3
- ✅ **Auto-Scaling** — Pay only for what you use
- ✅ **ECR Lifecycle Policies** — Automatically delete old images

### Production Recommendations

- Use one NAT Gateway per AZ for high availability
- Enable VPC Flow Logs for security auditing
- Implement predictive scaling for known traffic patterns
- Set up budget alerts in AWS Cost Explorer

---

## 🧹 Cleanup

Destroy resources in reverse order to avoid dependency issues:

```bash
# 1. Destroy dev environment
cd terraform/live/dev
terraform destroy

# 2. Destroy ECR repository
cd terraform/global/ecr
terraform destroy

# 3. Destroy S3 backend (set prevent_destroy = false first)
cd terraform/bootstrap
terraform destroy
```

---

## 🛠️ Troubleshooting

### Workers Not Connecting to Temporal

- ✅ Verify secrets in AWS Secrets Manager
- ✅ Check security group allows outbound HTTPS (port 443) and Temporal port (7233)
- ✅ Confirm NAT Gateway is routing traffic correctly
- ✅ Review CloudWatch logs for connection errors

### ECS Tasks Failing to Start

- ✅ Check ECR image exists and is accessible
- ✅ Verify IAM task execution role has ECR pull permissions
- ✅ Ensure sufficient vCPU/memory allocation
- ✅ Review ECS service events in AWS Console

### Terraform State Lock Issues

- ✅ Check S3 bucket versioning is enabled
- ✅ Verify `use_lockfile = true` in backend configuration
- ✅ Wait for concurrent operations to complete

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Development Workflow

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📚 Additional Resources

- [Temporal Documentation](https://docs.temporal.io/)
- [AWS ECS Best Practices](https://docs.aws.amazon.com/AmazonECS/latest/bestpracticesguide/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Fargate Documentation](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html)

---

## 📧 Contact

**Nora** — [nori.753@gmail.com](mailto:nori.753@gmail.com)

- LinkedIn: [@norapap753](https://www.linkedin.com/in/norapap753/)
- Project: [Skinsight.me](https://skinsight.me/) 💜

---

## 🙏 Acknowledgments

- Built with ❤️ for teams seeking cost-effective Temporal deployments
- Inspired by the need for simpler alternatives to Kubernetes
- Special thanks to the Temporal and AWS communities
- But most and foremost to [Rafay](https://www.linkedin.com/in/rafay-khan-02939b145/) - whose relentless drive, guidance, and hands-on contributions not only shaped this project but continue to inspire everyone around him 💪✨ None of this would’ve come together without his push to make it happen 😊💜
---

<div style="text-align: center;">

**If this helped you, consider giving it a ⭐!**

Made with 🧙‍♂️ by Nora From  🇭🇺
</div>