output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.techcorp_vpc.id
}

output "lb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.public_lb.dns_name
}

output "bastion_public_ip" {
  description = "Public IP of the Bastion Host"
  value       = aws_instance.bastion.public_ip
}

output "web_server_1_private_ip" {
  description = "Private IP of Web Server 1"
  value       = aws_instance.web_1.private_ip
}

output "web_server_2_private_ip" {
  description = "Private IP of Web Server 2"
  value       = aws_instance.web_2.private_ip
}

output "db_server_private_ip" {
  description = "Private IP of the Database Server"
  value       = aws_instance.db_server.private_ip
}
