resource "aws_ecs_task_definition" "teamcity_server" {
  family                = "teamcity-server"
  container_definitions = "${file("task-definitions/teamcity-server.json")}"
  network_mode          = "bridge"

  volume {
    name      = "datadir"
    host_path = "/opt/teamcity_data_dir"
  }

  volume {
    name      = "logdir"
    host_path = "/opt/teamcity_log_dir"
  }
}

resource "aws_ecs_service" "server" {
  depends_on = ["aws_autoscaling_group.teamcity", "aws_launch_configuration.teamcity"]

  name            = "teamcity-server"
  cluster         = "${aws_ecs_cluster.teamcity.id}"
  task_definition = "${aws_ecs_task_definition.teamcity_server.arn}"
  desired_count   = 1
  iam_role        = "${aws_iam_role.teamcity_service.arn}"
  depends_on      = ["aws_iam_role_policy.teamcity_service"]

  load_balancer {
    elb_name       = "${aws_elb.teamcity.name}"
    container_name = "server"
    container_port = 8111
  }
}

resource "aws_elb" "teamcity" {
  name            = "teamcity-server-elb"
  subnets         = ["${aws_subnet.teamcity_a.id}", "${aws_subnet.teamcity_b.id}", "${aws_subnet.teamcity_c.id}"]
  security_groups = ["${aws_security_group.teamcity_elb.id}"]

  listener {
    instance_port     = 8111
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags {
    project = "teamcity"
  }
}

resource "aws_iam_role" "teamcity_service" {
  name = "teamcity-service-iam-role"

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

resource "aws_iam_role_policy" "teamcity_service" {
  name = "teamcity-service-iam-role-policy"
  role = "${aws_iam_role.teamcity_service.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
        "ec2:Describe*",
        "ec2:AuthorizeSecurityGroupIngress"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}
