# hoge
resource "aws_alb" "redash" {
  name                       = "redash"
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb.id]
  drop_invalid_header_fields = true
  preserve_host_header       = false
  subnets = [
    aws_subnet.public_1a.id,
    aws_subnet.public_1c.id
  ]
  idle_timeout               = 120
  enable_deletion_protection = false
  enable_http2               = true
  enable_waf_fail_open       = true
}

resource "aws_alb_listener" "redash_main" {
  load_balancer_arn = aws_alb.redash.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type  = "forward"
    order = 1

    forward {
      target_group {
        arn    = aws_alb_target_group.redash_blue_target_group.arn
        weight = 0
      }
      target_group {
        arn    = aws_alb_target_group.redash_green_target_group.arn
        weight = 100
      }
    }
  }
}

resource "aws_alb_target_group" "redash_blue_target_group" {
  name        = "redash-blue-target-group"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    healthy_threshold   = 3
    interval            = 300
    path                = "/ping"
    protocol            = "HTTP"
    unhealthy_threshold = 5
  }
}

resource "aws_alb_target_group" "redash_green_target_group" {
  name        = "redash-green-target-group"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    healthy_threshold   = 3
    interval            = 300
    path                = "/ping"
    protocol            = "HTTP"
    unhealthy_threshold = 5
  }
}
