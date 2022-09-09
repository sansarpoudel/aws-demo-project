output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnets_id" {
  value = ["${aws_subnet.public_subnet.*.id}"]
}

output "private_subnets_id" {
  value = ["${aws_subnet.private_subnet.*.id}"]
}

output "security_groups_ids" {
  value = ["${aws_security_group.public_sg.id}"]
}

output "public_route_table" {
  value = aws_route_table.public_route_table.id
}

output "app_load_balancer" {
  value = aws_lb.app_load_balancer.dns_name
}
