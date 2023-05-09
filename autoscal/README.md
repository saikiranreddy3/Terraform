### Creating an autoscaling with application loadbalancer.
```
module "asg" {
  source                    = "source of the module"
  region                    = "us-east-2"
  image_id                  = ""
  instance_type             = "t2.micro"
  launch_configuration_name = "Launch-Lamp-application"
  key_name                  = ""
  loadbalancer_name         = ""
  loadbalancer_type         = ""
  security_group_ids        = [""]
  subnet_ids                = [""]
  target_group_name         = ""
  target_type               = "instance"
  vpc_id                    = ""
  protocol_type             = "HTTP"
  path                      = "/info.php"
  asg_name                  = ""
  asg_up                    = ""
  asg_down                  = ""
  policy_type               = "SimpleScaling"
  cooldown                  = 60
  adjustment_type           = "ChangeInCapacity"
  alarm_up_name             = "web_cpu_alarm_up"
  alarm_down_name           = "web_cpu_alarm_down"
  period                    = 120
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  statistic                 = "Average"
  comparison_operator_up    = "GreaterThanOrEqualToThreshold"
  comparison_operator_down  = "LessThanOrEqualToThreshold"
  project                   = ""
  createdby                 = "Terraform"
}
```