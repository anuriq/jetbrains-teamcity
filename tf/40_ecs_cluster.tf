resource "aws_key_pair" "teamcity" {
  key_name   = "${var.aws_keypair_name}"
  public_key = "${file(var.aws_keypair_file)}"
}

resource "aws_launch_configuration" "teamcity" {
  name                        = "teamcity-ecs"
  image_id                    = "${var.aws_ami_id}"
  instance_type               = "t2.medium"
  associate_public_ip_address = true
  key_name                    = "${aws_key_pair.teamcity.key_name}"
  security_groups             = ["${aws_security_group.teamcity_server.id}"]
  iam_instance_profile        = "${aws_iam_instance_profile.teamcity_cluster.name}"
  user_data                   = "#!/bin/bash\necho ECS_CLUSTER=${aws_ecs_cluster.teamcity.name} > /etc/ecs/ecs.config"
}

resource "aws_autoscaling_group" "teamcity" {
  name                 = "teamcity-ecs-asg"
  vpc_zone_identifier  = ["${aws_subnet.teamcity_a.id}", "${aws_subnet.teamcity_b.id}", "${aws_subnet.teamcity_c.id}"]
  launch_configuration = "${aws_launch_configuration.teamcity.name}"
  min_size             = 1
  max_size             = 5
  desired_capacity     = 1
}

resource "aws_ecs_cluster" "teamcity" {
  name = "teamcity-cloud"
}

resource "aws_iam_instance_profile" "teamcity_cluster" {
  name  = "teamcity-ecs-instance-profile"
  path  = "/"
  roles = ["${aws_iam_role.teamcity_cluster.name}"]
}

resource "aws_iam_role" "teamcity_cluster" {
  name = "teamcity-iam-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ecs.amazonaws.com", "ec2.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "teamcity_cluster" {
  name = "teamcity-iam-role-policy"
  role = "${aws_iam_role.teamcity_cluster.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:CreateCluster",
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ecs:RegisterContainerInstance",
        "ecs:StartTelemetrySession",
        "ecs:Submit*",
        "ecs:StartTask"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
