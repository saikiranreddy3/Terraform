locals {
  tags = {
    Project = var.project
    CreateBy = var.createdby
    #Creation = timestamp()
    #Environment = terraform.workspace
  }
}
provider "aws" {
  region     = var.region
}
###########################################
#Create a launch configuration for autoscale
###########################################
resource "aws_launch_configuration" "this" {
  name                        = var.launch_configuration_name
  image_id                    = var.image_id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  key_name                    = var.key_name
}

#########################################
# Creating Autoscalling Policy to Scale Up
#########################################

resource "aws_autoscaling_policy" "mygroup_policy_up" {
  name                   = var.asp-up
  policy_type            = var.policy_type
  scaling_adjustment     = 1                          # The number of instances by which to scale.
  adjustment_type        = var.adjustment_type
  cooldown               = var.cooldown                         # The amount of time (seconds) after a scaling completes and the next scaling starts.
  autoscaling_group_name = aws_autoscaling_group.asg.name
}
##########################################
# Creating Cloud metrics alarm to Scale Up
##########################################
resource "aws_cloudwatch_metric_alarm" "web_cpu_alarm_up" {
  alarm_name          = var.alarm_up_name # defining the name of AWS cloudwatch alarm
  comparison_operator = var.comparison_operator_up
  evaluation_periods  = 1
  metric_name         = var.metric_name    
  namespace           = var.namespace      
  period              = var.period                 # After AWS Cloudwatch Alarm is triggered, it will wait for 60 seconds and then autoscales
  statistic           = var.statistic
  threshold           = 50                  # CPU Utilization threshold is set to 60 percent
  actions_enabled     = true
  alarm_actions = [
    aws_autoscaling_policy.mygroup_policy_up.arn
  ]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
  tags = merge({"ResourceName" = "${var.project}-alarm-up"},local.tags)
}

############################################
# Creating Autoscalling Policy to Scale Down
############################################
resource "aws_autoscaling_policy" "mygroup_policy_down" {
  name                   = var.asp-down
  policy_type            = var.policy_type
  scaling_adjustment     = -1
  adjustment_type        = var.adjustment_type
  cooldown               = var.cooldown
  autoscaling_group_name = aws_autoscaling_group.asg.name

}
##############################################
# Creating Cloud metrics alarm to Scale Down
##############################################
resource "aws_cloudwatch_metric_alarm" "web_cpu_alarm_down" {
  alarm_name          = var.alarm_down_name                  # defining the name of AWS cloudwatch alarm
  comparison_operator = var.comparison_operator_down
  evaluation_periods  = 1
  metric_name         = var.metric_name     
  namespace           = var.namespace        
  period              = var.period                                  # After AWS Cloudwatch Alarm is triggered, it will wait for 30 seconds and then autoscales
  statistic           = var.statistic
  threshold           = 30                                    # CPU Utilization threshold is set to 10 percent
  actions_enabled     = true
  alarm_actions = [
    aws_autoscaling_policy.mygroup_policy_down.arn
  ]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
  tags = merge({"ResourceName" = "${var.project}-alarm-Down"},local.tags)
}

#############################
# Application LoadBalancer
##############################
resource "aws_lb" "test" {
  name               = var.loadbalancer_name
  internal           = false
  load_balancer_type = var.loadbalancer_type
  security_groups    =  var.security_group_ids
  subnets            = var.subnet_ids
  tags = merge({"ResourceName" = "${var.project}-alb"},local.tags)
}

##############################
# ALB Target Group
##############################

resource "aws_lb_target_group" "this" {
    name = var.target_group_name
    target_type = var.target_type
    protocol = var.protocol_type
    port = 80
    vpc_id = var.vpc_id
    health_check {
      protocol = var.protocol_type
      path = var.path
      healthy_threshold = 2
      unhealthy_threshold = 3
      timeout = 5
      interval = 10
      matcher = "200-299"
    }
    tags = merge({"ResourceName" = "${var.project}-tgp"},local.tags)

}
###############################
# Adding Listener to target group
###############################

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.test.arn
  port              = "80"
  protocol          = var.protocol_type
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
  #ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"
}

#####################################
# Autoscale group creation
#####################################
resource "aws_autoscaling_group" "asg" {
    name = var.asg_name
    max_size                  = 5
    min_size                  = 2
    health_check_grace_period = 60
    health_check_type         = "ELB"
    force_delete              = true
    launch_configuration      = aws_launch_configuration.this.name
    vpc_zone_identifier       = var.subnet_ids
    target_group_arns = [aws_lb_target_group.this.arn]
    termination_policies = ["NewestInstance"]
    enabled_metrics = [
        "GroupMinSize",
        "GroupMaxSize",
        "GroupDesiredCapacity"
    ]
    metrics_granularity = "1Minute"
    depends_on = [ aws_lb.test ]
    tag {
        key = "Name"
        value= ("${var.project}-asg")
        propagate_at_launch = true
    }
}

##############################################
# Create a launch template this is advanced resource of launch configuration
##############################################
/*resource "aws_launch_template" "this" {
  name = "${var.project}-template"
  image_id = var.image_id
  instance_type = var.instance_type
  key_name = var.key_name
  #user_data = filebsed(${path})

  network_interfaces {
    associate_public_ip_address = true
    security_groups = var.security_group_ids
  }
  tag_specifications {
    resource_type = "instance"
    tags = merge({"ResourceName" = "${var.project}-template"}, local.tags)
  }
}*/