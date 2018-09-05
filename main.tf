# Specify the provider and access details
provider "aws" {
  region = "ap-southeast-1"
}

### Network

data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block = "10.100.0.0/16"
  tags {
    Name = "${var.tag_name}-vpc"
 }
}

resource "aws_subnet" "main" {
  count             = "${var.az_count}"
  cidr_block        = "${cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  vpc_id            = "${aws_vpc.main.id}"
  
  tags {
    Name = "${var.tag_name}-subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"
  
  tags {
    Name = "${var.tag_name}-igw"
  }
}

resource "aws_default_route_table" "main" {
  default_route_table_id = "${aws_vpc.main.default_route_table_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
  
  tags {
    Name = "${var.tag_name}-rt"
  }
}

resource "aws_route_table_association" "a" {
  count          = "${var.az_count}"
  subnet_id      = "${element(aws_subnet.main.*.id, count.index)}"
  route_table_id = "${aws_vpc.main.main_route_table_id}"
}

### Security

resource "aws_security_group" "instance_sg" {
  description = "controls access to the application server"

  vpc_id = "${aws_vpc.main.id}"
  name   = "${var.tag_name}-sg"

  ingress {
    protocol  = "tcp"
    from_port = 0
    to_port   = 65535
    cidr_blocks = [
      "${aws_vpc.main.cidr_block}",
    ]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2

resource "aws_instance" "fc_jenkins_server" {
  vpc_security_group_ids = ["${aws_security_group.instance_sg.id}"]

  key_name                    = "${var.key_name}"
  ami                    = "ami-02a6e83f2f0a37903"
  instance_type               = "t2.medium"
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.main.0.id}"

  lifecycle {
    create_before_destroy = true
  }
  
  tags {
    Name = "${var.tag_name}-jenkins"
 }

}