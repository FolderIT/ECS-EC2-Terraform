## **Deploying an ECS Cluster on EC2 instances with Terraform**
Amazon Elastic Container Service (ECS) provides two options for running containers: ECS with EC2 and ECS with Fargate. Each option has its advantages, and choosing the right one for your workload depends on your specific requirements. Below are some benefits associated with each choice:

Advantages of ECS with EC2:

-   More control: With ECS with EC2, you have more control over the underlying EC2 instances, including the ability to customize the instance type, operating system, and networking settings.
-   Cost-effective: ECS with EC2 is generally more cost-effective than Fargate for long-running workloads, especially if you have spare EC2 capacity in your environment.
-   Familiarity: If you are already using EC2 instances for other workloads, then it may be easier to use ECS with EC2 as it’s similar to what you're already using.

Advantages of ECS with Fargate:

-   Serverless: Fargate is a serverless option for running containers, which means you don't need to worry about managing and maintaining the underlying infrastructure. This can be a big advantage for workloads that require a high level of scalability or don't have predictable traffic patterns.
-   Simplified management: Fargate eliminates the need to manage and maintain the underlying EC2 instances, making it a simpler option for managing containers.
-   Pay-as-you-go: With Fargate, you only pay for the resources you use, making it a more cost-effective option for short-lived workloads or workloads with unpredictable traffic patterns.

This post will discuss the use case scenario of EC2-ECS. The main advantage of using EC2 instead of Fargate is the fixed price. When you setup your instances, you select the size that better fits your needs and it’s easy to calculate the monthly cost given that EC2 with ECS is nothing more than a normal EC2 instance that runs a container-optimized image (AWS AMI) and the containers that run inside it communicate with ECS through an agent.

On this example we will deploy the following infrastructure with terraform:

![alt text](/BlogPost.jpg)

A brief explanation of the primary resources' functionality:

-   NAT Gateway: Since the EC2 instance is on a private subnet and it won't have a public IP, it’ll require a NAT (Network Address Translation, that is a way to map multiple local private addresses to a public one before transferring the information)
-   ECS Cluster: The one that will manage the containers
-   EC2 Instance: The one on which the containers will run
-   Application Load Balancer: A scalable and efficient load balancer that distributes incoming traffic across multiple targets based on application-level information.
-   ACM Certificates: To secure the traffic between the client and the Load Balancer with HTTPS
-   Internet Gateway: It serves as a gateway to connect the VPC to the internet, enabling internet access for resources within the VPC.

Once you have obtained the code, the only modification required is to update the domain. The terraform code assumes that you have a route53 domain directed to the AWS account where it’ll be deployed. To make the necessary changes, navigate to the "variables.tf" file and update the values of both the "domain_name" and "r53_zone_id" variables to your own domain. Additionally, it utilizes the AWS credentials that have been set up under the "blog" profile. You have the option to modify the profile name or configure your profile with aws configure --profile <name>

After that, run the following command to get terraform dependencies downloaded

`terraform init`

And finally, you can apply the code:

`terraform apply`

    PS ECS-EC2> terraform apply
    data.template_file.user_data: Reading...
    data.template_file.task_definition_json: Reading...
    data.template_file.user_data: Read complete after 0s [id=806b79ba9b20cfdb8ec89a3c36c92254a6429fa678c49c196f836d22fed8d3b6]
    data.template_file.task_definition_json: Read complete after 0s [id=bca4ec17cec71fb09cde60c7f21e049df1b52a551a8bdad3182c87c7f2b30c1b]
    data.aws_iam_policy_document.ecs_agent: Reading...
    data.aws_iam_policy_document.ecs-instance-policy: Reading…
    …

After a couple of seconds, it’ll prompt for confirmation to start creating resources:

    Do you want to perform these actions?
    Terraform will perform the actions described above.
    Only 'yes' will be accepted to approve.
    Enter a value:

It’ll be completed in a few minutes:

    aws_route53_record.www: Still creating... [30s elapsed]
    aws_route53_record.www: Creation complete after 35s [id=Z002051618M4QHG4VM3M6_cmcloudlab1035.info_A]
    
    Apply complete! Resources: 50 added, 0 changed, 0 destroyed.

Afterward, you’ll be able to see the default nginx screen on your root domain, which means that all the resources were created correctly.

Now you can change this image for whichever you need to deploy by changing the “container_image” variable on the variables.tf file.

In that case, also pay attention to the port number property on ecs.tf, alb.tf, security-groups.tf and task_definition.json to match the port of your container.