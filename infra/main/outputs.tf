output "public_subnets" {
  description = "Public subnet IDs for the ECS service"
  value       = [aws_subnet.email_read_receipts_1.id, aws_subnet.email_read_receipts_2.id]
}

output "ecs_security_group" {
  description = "Security group for ECS tasks"
  value       = aws_security_group.ecs_sg.id
}

output "alb_target_group_arn" {
  description = "ARN of the ALB target group"
  value       = aws_lb_target_group.ecs_tg.arn
}

output "ecr_image_uri" {
  description = "ECR image URI for the tracking pixel app"
  value       = local.ecr_image_uri
}

output "region" {
  description = "AWS region"
  value       = "eu-west-1"
}
