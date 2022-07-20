provider "aws" {
  profile = "default"
  region  = "us-east-1" #ami-0cff7528ff583bf9a #Amazon Linux 2 Kernel 5.10 AMI 2.0.20220606.1 x86_64 HVM gp2
}

resource "aws_key_pair" "keypair" {
  key_name   = "Crash-Server"
  public_key = file("Crash-Server.pub")
}

##############################
# 1. Aprovisionar al menos 3 instancias EC2:     Server Name = Crash-Server _N
##############################
#source : https://www.youtube.com/watch?v=cCBd36n4RBU
resource "aws_instance" "base" {
  ami                    = "ami-0cff7528ff583bf9a"
  instance_type          = "t2.micro"
  count                  = 3 #El numero de instancias
  key_name               = aws_key_pair.keypair.key_name
  vpc_security_group_ids = [aws_security_group.allow_ports.id]
  user_data              = file("./deploy.sh")
  tags = {
    Name = "Crash-Server_{count.index}"
  }
}

#VPC which stands for Virtual Private Network allows you to launch AWS resources in a (virtual) network you define and completely control

resource "aws_eip" "myeip" {
  count    = length(aws_instance.base)
  vpc      = true
  instance = element(aws_instance.base.*.id, count.index)
  tags = {
    Name = "eip-Crash-Server_{count.index + 1}"
  }
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Deafult VPC"
  }
}


##############################
# 4. Create Segurity Groups
##############################
resource "aws_security_group" "allow_ports" {
  name        = "allow_ports1"
  description = "Allow inbound traffic"
  vpc_id      = aws_default_vpc.default.id
  ingress {
    description      = "http from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }

  ingress {
    description      = "tomcat port from VPC"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ports1"
  }

}

data "aws_subnet_ids" "subnet" {
  vpc_id = aws_default_vpc.default.id
}

##############################
# 3. Crear Target Groups (Instancias y Balanceador de Cargas)
##############################
resource "aws_lb_target_group" "my-target-group" {
  health_check {
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  name        = "my-test-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_default_vpc.default.id
}


##############################
# 2. Crear un Load Balancer
##############################
#Load Balancer source: https://www.youtube.com/watch?v=cgq92b0W_AA
resource "aws_lb" "my-aws-alb" {
  name     = "Crash-Server-test-alb"
  internal = false
  security_groups = [
    "${aws_security_group.allow_ports.id}"
  ]
  subnets = data.aws_subnet_ids.subnet.ids

  tags = {
    Name = "allow_ports1"
  }

  ip_address_type    = "ipv4"
  load_balancer_type = "application"
}

resource "aws_lb_listener" "Crash-Server-test-alb-listener" {
  load_balancer_arn = aws_lb.my-aws-alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.my-target-group.arn
    type             = "forward"
  }
}

resource "aws_alb_target_group_attachment" "ec2_attach" {
  count            = length(aws_instance.base)
  target_group_arn = aws_lb_target_group.my-target-group.arn
  target_id        = aws_instance.base[count.index].id
}
