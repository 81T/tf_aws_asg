//
// Module: tf_aws_asg
//

// This template creates the following resources
// - A launch configuration
// - A auto-scaling group
// - It's meant to be used for ASGs that *don't*
//   need an ELB associated with them.

resource "aws_launch_configuration" "launch_config" {
    name = "${var.lc_name}"
    image_id = "${var.ami_id}"
    instance_type = "${var.instance_type}"
    iam_instance_profile = "${var.iam_instance_profile}"
    key_name = "${var.key_name}"
    security_groups = ["${var.security_groups}"]
    user_data = "${file(var.user_data)}"
    enable_monitoring = "${var.instance_monitoring}"
}

resource "aws_autoscaling_group" "main_asg" {
  //We want this to explicitly depend on the launch config above
  depends_on = ["aws_launch_configuration.launch_config"]
  name = "${var.asg_name}"

  // Split out the AZs string into an array
  // The chosen availability zones *must* match
  // the AZs the VPC subnets are tied to.
  availability_zones = ["${var.azs}"]
  // Split out the subnets string into an array
  vpc_zone_identifier = ["${var.subnet_azs}"]

  // Uses the ID from the launch config created above
  launch_configuration = "${aws_launch_configuration.launch_config.id}"

  max_size = "${var.asg_number_of_instances}"
  min_size = "${var.asg_minimum_number_of_instances}"
  desired_capacity = "${var.asg_number_of_instances}"
  health_check_grace_period = "${var.health_check_grace_period}"
  health_check_type = "${var.health_check_type}"

  enabled_metrics = ["${var.asg_metrics}"]

  tag = {
    key = "Name"
    value = "${var.tag_name}"
    propagate_at_launch = true
  }
}
