# aws-demo-project
 
 ## Overview
 This project creates various AWS Services includiing VPC, Subnets, Internet Gateways, Routing table, NAT Gateway, Elastic IP, Security Groups, EC2 Key Pair, ssm parameter, EC2 Instance, Load balancer, target groups, listners, and Amazon RDS DB instance.

The EC2 instance will run in private subnet. It will have a nginx docker container running that can be reached directly from the internet using the Application load balancer.
 
 ## Pre-requisties - Required
 
 1. You need to install terrafom on the machine that you are running this module from . Recommended version v1.2.0 or higher
 2. You need to create the service account for terraform user in the AWS environment that you are working on. Steps to create the service user:
     
      a) Log into the AWS console as administrator
      
      b) Click Services --> IAM --> Users --> Add users --> give username as `terraform` --> Under Select AWS access type, select Access Key - Programatic       access --> Click Next on lower right corner --> Under set permissions, select Attach existing policies directly --> Under policy name select          AdministratorAccess --> Click Next --> Add Tags as necessary --> Click Next to review, if everything looks ok, click create user.
      
      c) Copy the access key ID and Secret access key and save it on a safe place.
      
      d) Install aws-cli using Amazon documentation available here [aws-cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
      
      e) On command line on the machine you intend to run terraform from, run `aws configure` and when it asks for `AWS Access Key ID` and `AWS Secret Access Key` pass the values that you saved on step c above.
      
## Pre-requisties - Optional 

It's a good practice to use S3 bucket as a backend to store the terraform state file. If you want to use S3 as a backend, use this module to create the S3 bucket. If not this module will use the local backend

## How to use this module

1) git clone this project
2) cd into the aws-demo-project
3) Run `terraform init` to initialize
4) Run `terraform plan` to plan. Verify the resources being created looks good to you
5) Run `terraform apply`. Pass `yes` for confirmation
6) Once apply is done, log into the console to verify resources are created as expected

## How to access nginx web server from the internet
1) Log into the console. Under Services, ec2, Load Balancing, click Load Balancers. Select the Load balancer it was created from this module. Grab the DNS name and paste it on the search bar of your favourite web browser. It should server the content of html file from the nginx container. TO DO: Create the DNS record for the load balancer so that easier URL can be created.



   
 
 
