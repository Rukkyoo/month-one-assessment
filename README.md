# TechCorp Web Application Infrastructure

This Terraform configuration provisions a highly available web application infrastructure on AWS for TechCorp.

## Infrastructure Overview

- **VPC**: Custom VPC with public and private subnets across two Availability Zones.
- **Networking**: Internet Gateway, NAT Gateways, and Route Tables.
- **Security**: Security Groups for Bastion, Web Servers, and Database.
- **Compute**:
  - Bastion Host (Public Subnet)
  - 2x Web Servers (Private Subnets) running Apache
  - 1x Database Server (Private Subnet) running PostgreSQL
- **Load Balancing**: Application Load Balancer (ALB) distributing traffic to Web Servers.

## Prerequisites

1.  **Terraform**: Ensure Terraform is installed (v1.0+).
2.  **AWS CLI**: Configured with appropriate credentials (`aws configure`).
3.  **SSH Key Pair**: An existing EC2 Key Pair in the target region (default: `us-east-1`).

## Deployment Steps

1.  **Clone the repository**:

    ```bash
    git clone <repository-url>
    cd terraform-assessment
    ```

2.  **Initialize Terraform**:

    ```bash
    terraform init
    ```

3.  **Configure Variables**:
    Create a `terraform.tfvars` file based on the example:

    ```bash
    cp terraform.tfvars.example terraform.tfvars
    ```

    Edit `terraform.tfvars` and update the values, especially `key_pair_name` and `IP_Address` (for Bastion access).

4.  **Review the Plan**:

    ```bash
    terraform plan
    ```

5.  **Apply the Configuration**:

    ```bash
    terraform apply
    ```

    Type `yes` when prompted.

6.  **Access the Application**:
    - Wait for the Load Balancer to become active.
    - Copy the `lb_dns_name` from the outputs.
    - Paste it into your browser to see the web application.

## Accessing Servers

### Bastion Host

Use the `bastion_public_ip` output:

```bash
ssh -i <path-to-key.pem> ec2-user@<BASTION_PUBLIC_IP>
```

### Web/DB Servers (via Bastion)

1.  SSH into the Bastion host.
2.  From the Bastion, SSH into the private IPs (found in outputs):
    ```bash
    ssh ec2-user@<PRIVATE_IP>
    ```
    _Note: Password authentication is enabled. Default password: `qwerty12345` (Change immediately!)_

## Cleanup

To destroy the infrastructure and avoid costs:

```bash
terraform destroy
```

Type `yes` when prompted.
