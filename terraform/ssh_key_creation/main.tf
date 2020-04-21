provider "tls" {
  
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_ssm_parameter" "secret" {
  name        = "/${var.environment}/database/password/master"
  description = "The parameter description"
  type        = "SecureString"
  value       = tls_private_key.example.public_key_openssh

  tags = {
    environment = "${var.environment}"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "put key here"
  # TODO: add in proper key. From created SSH key. this is likely needed in the main compute file rather than this sub folder
}
