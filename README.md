# DevOps Course Project

This project demonstrates DevOps practices using:
- Python Flask application
- Docker containerization
- Terraform for infrastructure
- AWS Lambda for serverless deployment
- CI/CD with GitHub Actions
- Monitoring with Prometheus, Grafana, and Loki

## Project Structure

```
devops-cursova/
├── app.py                    # Flask app with AWS Lambda and Prometheus metrics support
├── Dockerfile                # Docker image configuration
├── .dockerignore             # Ignored Docker files
├── requirements.txt          # Python dependencies
├── terraform/                # Terraform configuration
│   ├── aws/                  # AWS Lambda configuration
│   │   ├── main.tf           # Main Terraform configuration for AWS
│   │   ├── variables.tf      # Variables for AWS configuration
│   │   └── outputs.tf        # AWS configuration outputs
│   └── local/                # Local Terraform configuration
│       ├── main.tf           # Main Terraform configuration for local deployment
│       └── outputs.tf        # Terraform outputs for local deployment
├── k8s-manifests/            # Kubernetes manifests for local deployment
│   ├── app/                  # Application manifests
│   │   ├── deployment.yaml   # Application deployment configuration
│   │   ├── service.yaml      # Application service configuration
│   │   └── namespace.yaml    # Application namespace configuration
│   └── monitoring/           # Monitoring system manifests
│       ├── prometheus-*.yaml # Prometheus configurations
│       ├── grafana-*.yaml    # Grafana configurations
│       ├── loki-*.yaml       # Loki configurations
│       └── promtail-*.yaml   # Promtail configurations
├── .github/                  # GitHub Workflows
│   └── workflows/
│       ├── ci.yml            # CI configuration
│       └── aws-deploy.yml    # AWS deployment configuration
└── tests/                    # Tests
    └── test_app.py           # Tests for the Flask application
```

## Requirements

### For Local Deployment
- Docker Desktop
- Minikube
- kubectl
- Terraform
- Python 3.9+

### For AWS Deployment
- AWS account with Free Tier access
- AWS CLI
- Terraform
- Python 3.9+

## AWS Lambda Deployment

The project is configured for serverless deployment on AWS Lambda using the Free Tier. This allows running the application without continuously operating servers, paying only for the actual resource usage.

### AWS Lambda Benefits for this Project:

1. **Free Tier**: AWS Lambda Free Tier includes 1 million free requests per month and 400,000 GB-seconds of compute time.
2. **Scaling**: Automatic scaling according to load.
3. **Cost-efficiency**: Pay only for the actual code execution time.
4. **API Gateway Integration**: Create a full-featured API for application access.

### AWS Account Setup

1. Create an AWS account: https://aws.amazon.com/free/
2. Create an IAM user with access rights to Lambda, API Gateway, S3, and IAM.
3. Generate access keys (Access Key ID and Secret Access Key).
4. Add the keys as secrets to your GitHub repository:
   - AWS_ACCESS_KEY_ID
   - AWS_SECRET_ACCESS_KEY

### Manual AWS Deployment

```bash
# Configure AWS CLI
aws configure

# Initialize and apply Terraform configuration
cd terraform/aws
terraform init
terraform apply -auto-approve

# View API Gateway URL
terraform output api_gateway_url
```

### Automatic Deployment via GitHub Actions

The project is configured for automatic deployment to AWS Lambda with each push to the main branch. GitHub Actions performs the following steps:

1. Run tests
2. Initialize Terraform
3. Deploy infrastructure on AWS
4. Output API Gateway URL

## Local Deployment

### 1. Install Required Tools

```powershell
# Using winget (Windows)
winget install Docker.DockerDesktop
winget install Kubernetes.minikube
winget install Kubernetes.kubectl
winget install HashiCorp.Terraform
winget install Python.Python.3.9
```

### 2. Start Docker

Launch Docker Desktop and wait for it to fully start.

### 3. Start Minikube

```powershell
minikube start
```

### 4. Deploy Docker Container with Terraform

```powershell
cd terraform/local
terraform init
terraform apply -auto-approve
```

### 5. Deploy to Kubernetes

```powershell
# Configure Minikube for local images
minikube docker-env --shell powershell | Invoke-Expression

# Build Docker image
docker build -t python-app:latest .

# Create namespaces
kubectl apply -f k8s-manifests/app/namespace.yaml
kubectl apply -f k8s-manifests/monitoring/namespace.yaml

# Deploy application
kubectl apply -f k8s-manifests/app/deployment.yaml
kubectl apply -f k8s-manifests/app/service.yaml

# Deploy monitoring system
kubectl apply -f k8s-manifests/monitoring/prometheus-config.yaml
kubectl apply -f k8s-manifests/monitoring/prometheus-server-pv.yaml
kubectl apply -f k8s-manifests/monitoring/prometheus-server-pvc.yaml
kubectl apply -f k8s-manifests/monitoring/prometheus-deployment.yaml
kubectl apply -f k8s-manifests/monitoring/prometheus-service.yaml

kubectl apply -f k8s-manifests/monitoring/grafana-datasource.yaml
kubectl apply -f k8s-manifests/monitoring/grafana-deployment.yaml
kubectl apply -f k8s-manifests/monitoring/grafana-service.yaml

kubectl apply -f k8s-manifests/monitoring/loki-config.yaml
kubectl apply -f k8s-manifests/monitoring/loki-deployment.yaml
kubectl apply -f k8s-manifests/monitoring/loki-service.yaml

kubectl apply -f k8s-manifests/monitoring/promtail-rbac.yaml
kubectl apply -f k8s-manifests/monitoring/promtail-configmap.yaml
kubectl apply -f k8s-manifests/monitoring/promtail-daemonset.yaml

# Check status
kubectl get pods -n monitoring
kubectl get pods -n python-app

# Open the application in browser
minikube service python-app -n python-app
```

## Development

1. Create a Python virtual environment:
```powershell
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
```

2. Make code changes
3. Run tests: `pytest`
4. For local testing of AWS Lambda functionality:
```powershell
pip install python-lambda-local
python-lambda-local -f lambda_handler app.py event.json
```

## Monitoring

### Local Monitoring Stack

The project uses a complete monitoring stack for local deployment:

1. **Prometheus** - metrics collection and storage
   - Configuration: `k8s-manifests/monitoring/prometheus-config.yaml`
   - Data storage: `prometheus-server-pv.yaml` and `prometheus-server-pvc.yaml`
   - Deployment: `prometheus-deployment.yaml` and `prometheus-service.yaml`

2. **Grafana** - metrics and logs visualization
   - Data sources: `grafana-datasource.yaml` (Prometheus and Loki)
   - Deployment: `grafana-deployment.yaml` and `grafana-service.yaml`
   - Access: http://localhost:3000 (after port-forward)
   - Login: admin / Password: admin

3. **Loki** - log aggregation and storage
   - Configuration: `loki-config.yaml`
   - Deployment: `loki-deployment.yaml` and `loki-service.yaml`

4. **Promtail** - container log collection
   - Configuration: `promtail-configmap.yaml`
   - Access rights: `promtail-rbac.yaml`
   - Deployment: `promtail-daemonset.yaml`

#### Application Metrics

The application provides the following metrics through the `/metrics` endpoint:

1. `app_request_count` - request counter by method, endpoint, and status
2. `app_request_latency_seconds` - response time histogram by method and endpoint

#### Accessing Monitoring Tools

```powershell
# Prometheus (metrics)
kubectl port-forward svc/prometheus-service 9090:9090 -n monitoring

# Grafana (dashboards and logs)
kubectl port-forward svc/grafana 3000:3000 -n monitoring
```

#### Viewing Logs in Grafana

1. Open Grafana: http://localhost:3000
2. Log in with credentials: admin / admin
3. Go to the "Explore" section
4. Select "Loki" data source
5. Use the query: `{namespace="python-app"}`

# Technical Documentation

Detailed technical documentation can be found at [TOYE-devops-project](https://github.com/OluwaTossin/TOYE-devops-project/wiki)
