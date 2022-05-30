resource "aws_launch_configuration" "EC2" {
  image_id        = data.aws_ami.ubuntu.id
  instance_type   = var.instance_type
  key_name        = var.key_name
  security_groups = [aws_security_group.EC2_sg.id]
  user_data       = templatefile("${path.module}/server.tftpl", {
    app_port        = var.app_port,
    app_target_port = var.app_target_port
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "EC2_asg" {
  count      = local.number_public_subnets
  vpc_zone_identifier  = [aws_subnet.public_subnet[count.index].id]
  launch_configuration = aws_launch_configuration.EC2.name

  min_size         = 1
  max_size         = 2
  desired_capacity = 1

  tag {
    key                 = "Name"
    value               = "EC2_asg"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "EC2_sg" {
  vpc_id = aws_vpc.vpc.id
  name   = "instance security group"
  dynamic "ingress" {
    for_each = var.ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "EC2_sg"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  count      = local.number_public_subnets
  autoscaling_group_name = aws_autoscaling_group.EC2_asg[count.index].id
  lb_target_group_arn    = aws_alb_target_group.web_server.arn
}