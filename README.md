# DevOps Python Application Project

This project demonstrates a complete DevOps pipeline for a Python Flask application, including containerization, infrastructure as code, CI/CD, and monitoring solutions.

## Project Overview

The project includes:

- Python Flask application with Prometheus metrics
- Docker containerization
- Kubernetes deployment manifests
- Terraform configurations for both local and AWS deployments
- CI/CD pipelines with GitHub Actions
- Monitoring stack with Prometheus, Grafana, Loki, and Promtail

## Repository Structure

```
.
├── app.py                 # Python Flask application
├── requirements.txt       # Python dependencies
├── Dockerfile             # Docker image configuration
├── tests/                 # Test files
├── k8s-manifests/         # Kubernetes configuration files
│   ├── app/               # Application manifests
│   └── monitoring/        # Monitoring stack manifests
├── terraform/             # Infrastructure as code
│   ├── aws/               # AWS deployment configuration
│   └── local/             # Local deployment configuration
└── .github/workflows/     # CI/CD pipeline configurations
```

## Getting Started

### Prerequisites

- Docker
- Kubernetes cluster (Minikube for local development)
- Terraform
- Python 3.9+

### Local Development

1. Clone the repository:
   ```
   git clone https://github.com/tye1o/devops-cursova.git
   cd devops-cursova
   ```

2. Set up a Python virtual environment:
   ```
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   pip install -r requirements.txt
   ```

3. Run the application locally:
   ```
   python app.py
   ```

4. Run tests:
   ```
   pytest
   ```

### Docker Deployment

Build and run the Docker container:

```
docker build -t python-app:latest .
docker run -d -p 3000:3000 --name python-app python-app:latest
```

### Terraform Deployment

#### Local Deployment with Docker

```
cd terraform/local
terraform init
terraform apply
```

#### AWS Deployment

```
cd terraform/aws
terraform init
terraform apply
```

### Kubernetes Deployment

Deploy the application:

```
kubectl apply -f k8s-manifests/app/namespace.yaml
kubectl apply -f k8s-manifests/app/
```

Deploy the monitoring stack:

```
kubectl apply -f k8s-manifests/monitoring/namespace.yaml
kubectl apply -f k8s-manifests/monitoring/
```

## CI/CD Pipeline

The project includes two GitHub Actions workflows:

1. **CI Pipeline** (`ci.yml`): Runs on every push and pull request to the main branch
   - Runs tests
   - Builds Docker image

2. **AWS Deployment** (`aws-deploy.yml`): Deploys the application to AWS Lambda
   - Runs tests
   - Applies Terraform configuration
   - Outputs the API Gateway URL

## Monitoring

The monitoring stack includes:

- **Prometheus**: For metrics collection
- **Grafana**: For metrics visualization
- **Loki**: For log aggregation
- **Promtail**: For log collection

Access Grafana at `http://localhost:3000` when deployed locally.

## Project Features

- Containerized application with Docker
- Infrastructure as code with Terraform
- Kubernetes deployment configurations
- CI/CD pipeline with GitHub Actions
- Monitoring and observability with Prometheus and Grafana
- Log aggregation with Loki and Promtail
- AWS Lambda deployment option

---

Based on "TOYE-devops-project"  
Please find the technical documentation to this project on the Wiki Page.

https://github.com/OluwaTossin/TOYE-devops-project/wiki
