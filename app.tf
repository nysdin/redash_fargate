# resource "aws_ecr_repository" "handy_rails_app" {
#   name                 = "handy-rails-app"
#   image_tag_mutability = "MUTABLE"
# }

# resource "aws_ecs_cluster" "handy_rails_app" {
#   name = "handy-rails-app"
# }

# resource "aws_ecs_service" "handy_rails_app" {
#   name                              = "rails"
#   cluster                           = aws_ecs_cluster.handy_rails_app.id
#   task_definition                   = "arn:aws:ecs:ap-northeast-1:292687378741:task-definition/rails:3"
#   desired_count                     = 1
#   launch_type                       = "FARGATE"
#   platform_version                  = "LATEST"
#   health_check_grace_period_seconds = 5
#   enable_execute_command            = true

#   network_configuration {
#     subnets = [
#       aws_subnet.public_1a.id,
#       aws_subnet.public_1c.id,
#     ]
#     security_groups  = [aws_security_group.redash.id]
#     assign_public_ip = true
#   }

#   load_balancer {
#     target_group_arn = aws_alb_target_group.rails_handy_app.arn
#     container_name   = "rails"
#     container_port   = 3000
#   }

#   lifecycle {
#     ignore_changes = ["task_definition"]
#   }
# }


# resource "aws_alb" "rails_handy_app" {
#   name               = "rails-handy-app"
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.alb.id]
#   subnets = [
#     aws_subnet.public_1a.id,
#     aws_subnet.public_1c.id,
#   ]
#   idle_timeout = 30
# }

# resource "aws_alb_listener" "rails_handy_app_http" {
#   load_balancer_arn = aws_alb.rails_handy_app.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_alb_target_group.rails_handy_app.arn
#   }
# }

# resource "aws_alb_target_group" "rails_handy_app" {
#   name        = "rails-handy-app"
#   port        = 3000
#   protocol    = "HTTP"
#   vpc_id      = aws_vpc.main.id
#   target_type = "ip"

#   health_check {
#     healthy_threshold   = 3
#     interval            = 60
#     timeout             = 10
#     path                = "/"
#     protocol            = "HTTP"
#     unhealthy_threshold = 5
#     matcher             = "200"
#   }
# }
