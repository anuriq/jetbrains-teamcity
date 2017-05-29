resource "aws_vpc" "teamcity" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true

  tags {
    Name    = "teamcity"
    project = "teamcity"
  }
}

resource "aws_route_table" "main" {
  vpc_id = "${aws_vpc.teamcity.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
    //nat_gateway_id = "${aws_nat_gateway.gw.id}"
  }

  tags {
    project = "teamcity"
  }
}

resource "aws_network_acl" "main" {
  vpc_id = "${aws_vpc.teamcity.id}"

  egress {
    protocol   = "all"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "all"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags {
    project = "teamcity"
  }
}

resource "aws_subnet" "teamcity_a" {
  vpc_id            = "${aws_vpc.teamcity.id}"
  cidr_block        = "10.10.0.0/22"
  availability_zone = "${var.aws_region}a"

  tags {
    project = "teamcity"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = "${aws_subnet.teamcity_a.id}"
  route_table_id = "${aws_route_table.main.id}"
}

resource "aws_subnet" "teamcity_b" {
  vpc_id            = "${aws_vpc.teamcity.id}"
  cidr_block        = "10.10.32.0/22"
  availability_zone = "${var.aws_region}b"

  tags {
    project = "teamcity"
  }
}

resource "aws_route_table_association" "b" {
  subnet_id      = "${aws_subnet.teamcity_b.id}"
  route_table_id = "${aws_route_table.main.id}"
}

resource "aws_subnet" "teamcity_c" {
  vpc_id            = "${aws_vpc.teamcity.id}"
  cidr_block        = "10.10.64.0/22"
  availability_zone = "${var.aws_region}c"

  tags {
    project = "teamcity"
  }
}

resource "aws_route_table_association" "c" {
  subnet_id      = "${aws_subnet.teamcity_c.id}"
  route_table_id = "${aws_route_table.main.id}"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.teamcity.id}"

  tags {
    project = "teamcity"
  }
}

/*
resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "gw" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.teamcity_c.id}"

  depends_on = ["aws_internet_gateway.gw"]
}
*/

resource "aws_security_group" "teamcity_anywhere" {
  name        = "ssh-from-anywhere"
  description = "Allow ssh from anywhere"
  vpc_id      = "${aws_vpc.teamcity.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    project = "teamcity"
  }
}

resource "aws_security_group" "teamcity_internal" {
  name        = "teamcity-vpc-internal"
  description = "Allow all ports inside private VPC"
  vpc_id      = "${aws_vpc.teamcity.id}"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16"]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["10.10.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    project = "teamcity"
  }
}

resource "aws_security_group" "teamcity_server" {
  name        = "teamcity-server-sg"
  description = "Allow teamcity server inside private VPC"
  vpc_id      = "${aws_vpc.teamcity.id}"

  ingress {
    from_port   = 8111
    to_port     = 8111
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    project = "teamcity"
  }
}

resource "aws_security_group" "teamcity_db" {
  name        = "teamcity-db-sg"
  description = "Allow MySQL port inside private VPC"
  vpc_id      = "${aws_vpc.teamcity.id}"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    project = "teamcity"
  }
}

resource "aws_security_group" "teamcity_elb" {
  name        = "teamcity-elb-sg"
  description = "Allow 80 from anywhere"
  vpc_id      = "${aws_vpc.teamcity.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    project = "teamcity"
  }
}
