output "aws_security_group_http_server_sg" {
  value = aws_security_group.elb_sg
}

output "http_server_public_dns" {
  value = aws_instance.http_servers.*.public_dns
}

output "elb_public_dns" {
  value = aws_elb.elb
}