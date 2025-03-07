## ---- Internet gateway ----- ##
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "email-tracking-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "email-tracking-public-rt"
  }
}

# associate subnets with route table
resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.email_read_receipts_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.email_read_receipts_2.id
  route_table_id = aws_route_table.public_rt.id
}

## --- Security group --- ##
resource "aws_security_group" "ecs_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    #aws sg allows all outbound traffic by default
  }
}

## ---- Load Balancer ---- ##
resource "aws_lb" "ecs_alb" {
  name               = "email-tracking-alb-2"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs_sg.id]
  subnets            = [aws_subnet.email_read_receipts_1.id, aws_subnet.email_read_receipts_2.id]
}

# Target Group for ECS
resource "aws_lb_target_group" "ecs_tg" {
  depends_on  = [aws_lb.ecs_alb]
  name        = "email-tracking-tg"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
}

# HTTP Listener for the ALB
resource "aws_lb_listener" "http" {
  depends_on        = [aws_lb_target_group.ecs_tg]
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg.arn
  }
}

