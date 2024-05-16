# terraform-ec2-instace-and-multi-http-server-project02
AWS Provider Configuration:
Specifies the required AWS provider with the region set to us-east-1 and the version locked to ~> 5.48.

Variables:
Defines a variable aws_key_pair with the default value pointing to the path of the EC2 key pair file.

AWS Security Group (aws_security_group):
Creates a security group named elb_sg to control inbound and outbound traffic.
Allows inbound HTTP (port 80) and SSH (port 22) traffic from anywhere.
Allows all outbound traffic.

Default VPC (aws_default_vpc):
Utilizes the default VPC provided by AWS.

Data Source (data.aws_subnet.default_subnets):
Fetches information about the default subnets within the specified availability zone (us-east-1a).

Elastic Load Balancer (aws_elb.elb):
Creates an Elastic Load Balancer named elb.
Spans across two availability zones (us-east-1a, us-east-1b).
Associates it with the security group elb_sg.
Sets up a listener to forward incoming HTTP requests (port 80) to instances.

AWS EC2 Instances (aws_instance.http_servers):
Launches EC2 instances based on a specified AMI (ami-07caf09b362be10b8) and instance type (t2.micro).
Uses the specified key pair (default-ec2) for SSH access.
Associates instances with the security group elb_sg.
Spawns six instances (count = 6) across the default subnets.
Tags each instance uniquely based on its index.

Provisioner (provisioner "remote-exec"):
Executes remote commands on each EC2 instance after provisioning.
Installs Apache HTTP server, starts it, and creates an HTML file with a welcome message containing the instance's public DNS.
Establishes an SSH connection to the instances using the specified key pair.

Considerations:
Ensure you have appropriate AWS credentials configured for Terraform.
Review security settings and adjust resources based on specific requirements and best practices.
Regularly update Terraform configurations to reflect changes in infrastructure needs.
