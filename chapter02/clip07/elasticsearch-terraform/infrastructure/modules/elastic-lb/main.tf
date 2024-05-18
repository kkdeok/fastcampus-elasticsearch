resource "aws_lb" "lb" {
  name               = var.name
  internal           = var.is_internal
  load_balancer_type = "application" # application load balancer

  security_groups = var.sg_ids
  subnets         = var.subnet_ids

  tags = {
    cluster : var.cluster_name
  }
}

resource "aws_lb_target_group" "tg" {
  for_each             = var.ports
  name                 = substr(md5("${var.name}-${each.value}"), 0, 32) // name length limit
  port                 = each.value
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = 90
  tags                 = {
    cluster : var.cluster_name,
  }

  depends_on = [aws_lb.lb]
}

resource "aws_autoscaling_attachment" "lb_asg_attachment" {
  for_each = aws_lb_target_group.tg

  autoscaling_group_name = var.tg_asg_name
  alb_target_group_arn   = aws_lb_target_group.tg[each.key].arn

  depends_on = [aws_lb_target_group.tg]
}

resource "aws_lb_listener" "listener" {
  for_each          = zipmap(keys(var.ports), keys(aws_lb_target_group.tg))
  load_balancer_arn = aws_lb.lb.arn
  port              = each.key
  protocol          = var.https.enabled ? "HTTPS" : "HTTP"
  certificate_arn   = var.https.enabled ? var.https.acm_cert_arn : null
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg[each.value].arn
  }
  depends_on = [aws_lb.lb, aws_lb_target_group.tg]
}
