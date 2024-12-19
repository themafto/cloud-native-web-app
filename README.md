This project provides a hands-on experience of building and deploying a scalable web application infrastructure on AWS using Terraform. It demonstrates practical techniques for managing infrastructure as code and automating deployments.

## Architecture

The application is deployed on AWS and uses the following services:

* **S3 (Simple Storage Service):**  Hosts the static frontend assets of the application, serving as a cost-effective and scalable solution for static website hosting.  
* **CloudFront:** CDN for caching the static frontend content from the S3 bucket and providing security with an SSL certificate. A custom domain is attached to CloudFront, providing a user-friendly URL.
* **ALB (Application Load Balancer):** Distributes incoming traffic between the ECS services based on routing rules.
* **ECS (Elastic Container Service):** Runs two containerized backend services: one for interacting with Redis, and another for working with the RDS database.
* **RDS (Relational Database Service):** Relational database for storing persistent application data.
* **ElastiCache (Redis):** In-memory data store used as a cache to improve application performance by reducing database load.
* **ECR (Elastic Container Registry):**  Stores the Docker images for the application's backend services.
* **Route53:** DNS service used for managing subdomains for each service, providing flexibility and better organization. For example, `api.example.com` might route to the backend services, while `example.com` routes to the frontend on S3 via CloudFront.
* **CloudWatch:** Provides monitoring and logging for the application and infrastructure, allowing easy tracking of performance metrics, resource utilization, and potential issues.

The entire infrastructure is divided into public and private subnets for security.

## Deployment

Application deployment is fully automated using Terraform. When you run `terraform apply`, the following happens:

1. The necessary infrastructure is created in AWS (ECS, ALB, RDS, ElastiCache, S3, CloudFront).
2. Scripts are executed that pull Docker images from ECR based on the current task definition. This allows for dynamic updates of services without downtime.

## CI/CD

A pipeline is used for continuous integration and delivery. Each new commit creates a Docker image tagged with the commit hash and uploads it to ECR. This allows for easy rollback to previous versions of the application if needed.

**Author:** Nazdrachov Artem
