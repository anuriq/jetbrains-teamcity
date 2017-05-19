# JetBrains Teamcity on AWS ECS

This repository contains files to bootstrap Teamcity infrastructure in AWS ECS (Container Service) using Terraform.

You should have AWS API account credentials and [Terraform](https://www.terraform.io/docs/providers/aws/r/elb.html) installed and ready.

### Usage
First review `tf/00_variables.tf` for deployment parameters. Change what you need to change. AWS API credentials may be specified there or through command line as follows:
```bash
cd tf
export TF_VAR_aws_access_key=The AWS access key ID
export TF_VAR_aws_secret_key=The AWS secret key
# see what will be done
terraform plan
# actual creation
terraform apply
```

### Roadmap
What is ready:
- Create VPC and security groups;
- Create RDS instance to host MySQL database;
- Create ECS cluster with EC2 instance to run containers;
- Create ECS task to run Teamcity Server using official image from Docker Hub;
- Create ELB to serve Teamcity Web Console.

What is not ready:
- EBS volume assignment to mount them to container;
- Teamcity Server does not have jdbc drivers ready in its data directory;
- Teamcity Agents deployment.
