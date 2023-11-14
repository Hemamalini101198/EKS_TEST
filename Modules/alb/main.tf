module "alb" {
  source = "terraform-aws-modules/alb/aws"
  version = "9.2.0"

  name               = var.alb_name
  subnets            = module.vpc.public_subnets
  vpc_id = module.vpc.vpc_id
  enable_deletion_protection = false
  internal           = false
  security_groups    = [""] 
  enable_http2       = true
  tags = {
    name = var.alb_tag_name
  }

  # Security Group
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = module.vpc.vpc_cidr_block
    }
  }
  listeners = {
    ex-http-https-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }
}