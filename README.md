# Ecommerce Docker Deployment

## Purpose
Building upon the previous workload, this continuation focuses on enhancing the deployment process for the ecommerce application by containerizing it. The goal is to deploy the containerized application to a secure, highly available, and fault-tolerant AWS Cloud Infrastructure. By leveraging Infrastructure as Code (IaC) and a robust CI/CD pipeline, this workload ensures seamless infrastructure management, enabling rapid deployment and modification of the application whenever updates are made to its source code. This approach further streamlines operations, reduces downtime, and supports scalability for future growth.


<div align="center">
	<img width="499" alt="image" src="https://github.com/user-attachments/assets/20c1d38e-28db-4da9-8bde-9dad74afe61c">
</div>




<div align="center">
	<img width="1137" alt="image" src="https://github.com/user-attachments/assets/481b8749-ec11-409f-9470-a25bf7820eb1">
</div>




## Steps Taken

1. **Manual Deployment for Understanding**:
   - Initially deployed the application manually on two EC2 instances in the development environment (Jenkins - the build master and the Docker-Terraform - the build-node) to understand the setup process. This step was crucial as it provided insights into the necessary configurations and potential challenges before automating them.

2. **Infrastructure Creation using Terraform (IaC)**:
   - Created multiple '.tf' files that defined all necessary resources for the application:
     - **VPC and Subnets**: Created a custom VPC (`wl6vpc`) and configured public and private subnets across two availability zones.
     - **EC2 Instances**: Deployed two EC2 instances for the frontend and two for the backend, ensuring proper security, redundancy/availability.
     - **Load Balancer**: Configured a load balancer to route traffic effectively between the frontend EC2s.
     - **RDS Database**: Added an RDS instance to store application data, enhancing data management and availability.

   - **Terraform Files Created**:
     - `ec2s.tf`: *This had all four EC2s creation code*
     - `main.tf`: *This had the custom VPC, VPC Peering between the two VPCs default and custom, load balancer. Then it also had Elastic IPs, (in both
       availability zones).*
     - `network.tf`: *This had the internet gateway, the two NAT gateways attached in the public subnets of both availability zones. Then, the
	public & private route tables (and their associations), the security groups; public, private and the RDS'*
     - `outputs.tf`: *This was to written to output the IP addresses of both frontend EC2s*
     - `providers.tf`: *This had the aws variable identifiers (for the key to be used for authenticating. The epecific details of these credentials 
	were passed in Jenkins though. More on that later.*
     - `rds.tf`: *This was the file showing housing how the RDS was to be created - with which infrastructure specifics.*
     - `security.tf`: *This was the file with the security groups controlling the ingress and egress traffic for all 4 EC2s and the RDS instance.*
     - `variables.auto.tf`: *This declared the region in which the infrastructure was to be placed in and the type of EC2s.*
     - `variables.tf`: *.This declared the variables that surface anywhere within the above .tf files, plus the credentials passed from Jenkins.*

3. **Jenkins CI/CD Pipeline**:
   - Expanded the Jenkins pipeline to incorporate Docker containerization and Terraform-based infrastructure deployment. The stages include:  
     - **Build**:
       - Set up a Python virtual environment.  
       - Upgraded `pip` and installed all required dependencies from the backend's `requirements.txt` file.  
     - **Test**:
       - Leveraged `pytest-django` to run Django-specific tests, ensuring code quality and functionality.  
       - Saved test results as XML reports for further analysis.  
     - **Cleanup**:
       - Incorporated an in-pipeline cleanup step to remove unused Docker objects, ensuring efficient resource utilization on the build node.  
     - **Build & Push Images**:
       - **Backend and Frontend**: Built Docker images for both backend and frontend components using their respective Dockerfiles.  
       - **Docker Hub**: Logged into Docker Hub using secure credentials and pushed the built images to the repository for deployment.  
     - **Infrastructure**:
       - Used Terraform within the pipeline to provision infrastructure in AWS.  
       - Passed Docker Hub credentials as variables for secure deployment of containerized applications.  
     - **Post**:
       - Logged out of Docker Hub and performed final cleanup to free up resources, ensuring the pipeline is ready for future runs.  

4. **Deployment Automation with deploy.sh Script**:
   - The deployment process was further automated using a robust `deploy.sh` script, streamlining the setup and configuration of essential services. This script begins by updating the system and installing
     prerequisites, followed by setting up Prometheus Node Exporter for system metrics monitoring. Docker and Docker Compose are installed and configured, enabling containerized application deployment. The
     script dynamically generates a `docker-compose.yml` file to orchestrate the deployment of services and ensures secure interactions with Docker Hub for image pulls. After pulling and recreating the
     application containers, unnecessary system resources are pruned to maintain efficiency. The entire process is logged with timestamps, ensuring traceability and reliability during deployments.

5. **Environment Variable Management**:
   - Used Jenkins Secret Manager to handle sensitive information, such as AWS credentials, ensuring security and compliance.

6. **Monitoring Setup**:
   - Deployed an additional EC2 instance in the default VPC for monitoring purposes to track the health and performance of the deployed resources in the custom VPC named _**wl6vpc**_.


<div align="center">
	<img width="822" alt="image" src="https://github.com/user-attachments/assets/ea337f58-59a1-47c2-87bd-75966d395967">
</div>


7. **Documentation**:
   - Created a comprehensive README file documenting the process, challenges faced, and potential optimizations for future iterations.


## Issues/Troubleshooting
- **Availability Zone Misconfiguration**: Initially deployed the infrastructure in the wrong availability zone, which required tearing down and redeploying both the development and production environments. This delay highlighted the importance of verifying region and availability zone settings during setup. The issue was resolved by thoroughly reviewing the Terraform configuration and ensuring alignment with the required deployment specifications.  

- **Resource Limitations on Build Node**: The build node experienced frequent resource exhaustion, causing builds to fail mid-pipeline. This necessitated multiple restarts and underscored the need for more robust hardware or optimized resource usage. To address this, I allocated additional resources to the build node and fine-tuned the Jenkins pipeline to ensure smoother operation.  


<div align="center">
	<img width="1368" alt="Pasted Graphic 106" src="https://github.com/user-attachments/assets/d6b97fb5-2632-4c42-a3bb-9b0f505d083f">
</div>


- **Missing Files and Application Misconfigurations**: Several critical files, including product images and configuration scripts, were missing from the repository. This required collaboration with more experienced full-stack engineers to locate or recreate the necessary files, ensuring the application could be built and deployed properly. The issue was resolved by consolidating the application files and creating a checklist to verify all required assets were present before deployment.  

- **RDS Database Connectivity Issues**: Despite having the rest of the infrastructure correctly configured and operational, connecting to the RDS database posed a significant challenge. Resolving this required extensive troubleshooting of database credentials, network configurations, and application settings. The solution involved refining the security group rules, ensuring correct environment variable mappings, and testing connectivity with a local development database before applying the final changes to the production environment.


## Optimization
- Future improvements could include:
  - **Auto-Scaling Groups for EC2 Instances**: Implementing auto-scaling groups to adjust EC2 resources based on traffic demand, improving cost efficiency and ensuring high availability by dynamically scaling the infrastructure.
  
  - **IAM Roles with Least Privilege**: Enhancing security by using IAM roles with the principle of least privilege to restrict access to resources, minimizing the risk of unauthorized access.
  
  - **Switching to AWS Cloud Monitoring**: Replacing Prometheus and Grafana with AWS-native tools like CloudWatch and X-Ray for seamless integration, quicker setup, and reduced operational overhead in monitoring infrastructure and application performance.
  
  - **Automating Infrastructure with Terraform Modules**: Using Terraform modules and workspaces to improve reusability, modularity, and management of infrastructure across different environments, ensuring consistent and scalable deployments.



## Conclusion
This workload demonstrates the integration of Docker, Terraform, and Jenkins to streamline the deployment and management of an ecommerce application in the cloud. By leveraging Infrastructure as Code (IaC), containerization, and CI/CD pipelines, we have established a scalable, reliable, and efficient infrastructure. This setup not only improves the automation of deployments but also enhances the flexibility and consistency of updates, enabling faster and more secure application delivery. Through the use of cloud-native tools, containerized environments, and modular infrastructure, this approach provides a solid foundation for modern development practices and ensures greater resilience in any production environment.
