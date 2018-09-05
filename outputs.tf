output "jenkins-server" {
  value = "${aws_instance.fc_jenkins_server.public_ip}"
}

output "key-name" {
  value = "${var.key_name}.pem"
}