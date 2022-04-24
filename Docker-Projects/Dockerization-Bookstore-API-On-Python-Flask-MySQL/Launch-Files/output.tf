output "endpoint_of_bookstore" {
  value = "http://${aws_instance.Docker-Bookstore.public_ip}"
}