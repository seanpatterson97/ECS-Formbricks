########################################################################################################################
## Internal Application Load Balancer in private subnets, accessed via CloudFront VPC Origin
########################################################################################################################

resource "aws_lb" "alb" {
  name            = "${var.project}-ALB-${var.environment}"
  internal        = true
  security_groups = [aws_security_group.alb.id]
  subnets         = aws_subnet.private.*.id

}

########################################################################################################################
## HTTP listener that forwards traffic to the target group
########################################################################################################################

resource "aws_lb_listener" "alb_default_listener_http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.service.arn
  }

}

########################################################################################################################
## Target Group for our service
########################################################################################################################

resource "aws_lb_target_group" "service" {
  name                 = "${var.project}-TargetGroup-${var.environment}"
  port                 = var.container_port
  protocol             = "HTTP"
  vpc_id               = aws_vpc.main.id
  deregistration_delay = 5
  target_type          = "ip"


  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 60
    matcher             = var.healthcheck_matcher
    path                = var.healthcheck_endpoint
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 30
  }

  depends_on = [aws_lb.alb]
}