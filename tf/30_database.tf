resource "aws_db_instance" "teamcity" {
  allocated_storage       = 20
  storage_type            = "gp2"
  engine                  = "mysql"
  engine_version          = "5.7.17"
  instance_class          = "db.t2.micro"
  multi_az                = false                                    // switch to true for production
  identifier              = "teamcitydbinstance"
  name                    = "teamcitydb"
  username                = "${var.teamcity_db_user}"
  password                = "${var.teamcity_db_pass}"
  db_subnet_group_name    = "${aws_db_subnet_group.teamcity.id}"
  parameter_group_name    = "default.mysql5.7"
  backup_retention_period = 1
  backup_window           = "Sun:05:00-Sun:08:00"
  maintenance_window      = "Sun:05:00-Sun:08:00"
  publicly_accessible     = false
  vpc_security_group_ids  = ["${aws_security_group.teamcity_db.id}"]
  skip_final_snapshot     = true                                     // remove for production

  tags {
    project = "teamcity"
  }
}

resource "aws_db_subnet_group" "teamcity" {
  name       = "teamcity_database_subnet_group"
  subnet_ids = ["${aws_subnet.teamcity_a.id}", "${aws_subnet.teamcity_b.id}", "${aws_subnet.teamcity_c.id}"]

  tags {
    project = "teamcity"
  }
}
