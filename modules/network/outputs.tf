output "vpc_id" {
  value = aws_vpc.this.id
}
output "private_subnet_a_id" {
  value = aws_subnet.private_a.id
}
output "private_subnet_c_id" {
  value = aws_subnet.private_c.id
}
