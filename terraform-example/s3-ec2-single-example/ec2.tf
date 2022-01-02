resource "aws_instance" "web" {
  ami           = "ami-0c5204531f799e0c6"
  instance_type = "t3.micro"

  tags = {
    Name = "HelloWorld"
  }
}
