resource "aws_efs_file_system" "teamcity_data_dir" {
  creation_token = "teamcity-data-dir"

  tags {
    project = "teamcity"
  }
}

resource "aws_efs_mount_target" "teamcity_data_dir" {
  file_system_id = "${aws_efs_file_system.teamcity_data_dir.id}"
  subnet_id      = "${aws_subnet.teamcity_c.id}"
  security_groups = ["${aws_security_group.teamcity_internal.id}"]
}

resource "aws_efs_file_system" "teamcity_log_dir" {
  creation_token = "teamcity-log-dir"

  tags {
    project = "teamcity"
  }
}

resource "aws_efs_mount_target" "teamcity_log_dir" {
  file_system_id = "${aws_efs_file_system.teamcity_log_dir.id}"
  subnet_id      = "${aws_subnet.teamcity_c.id}"
  security_groups = ["${aws_security_group.teamcity_internal.id}"]
}
