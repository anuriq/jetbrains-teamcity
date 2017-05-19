output "teamcity_server_address" {
  value = "${aws_elb.teamcity.dns_name}"
}

output "teamcity_db_address" {
  value = "${aws_db_instance.teamcity.address}"
}
