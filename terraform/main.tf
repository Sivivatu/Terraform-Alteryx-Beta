provider "aws" {
  region     = "eu-west-1" # var.AWS_REGION
}

module "networking" {
  source                = "./networking"
  VPC_CIDR              = var.VPC_CIDR
  PRIVATE_CIDRS         = var.PRIVATE_CIDRS
  ALLACCESSIPS          = var.ALLACCESSIPS
  ALLOWEDIPS            = var.ALLOWEDIPS
  AWS_AVAILABILITY_ZONE = var.AWS_AVAILABILITY_ZONE
}

# data "aws_s3_bucket_object" "secret_key" {
#   bucket = var.S3_KEY_BUCKET
#   key    = var.S3_KEY_NAME_LOCATION
# }

# Manually defined SSH key from System Manager
data "aws_ssm_parameter" "ssh" {
  name = "TIL-EUWest1"
}

# TODO: adding dynamic AMI selection process
# data "aws_ami" "ayx_ami" {
#   most_recent      = true
#   name_regex       = "Microsoft Windows Server 2019 Base"
#   owners           = ["amazon"]

#   # filter {
#   #   name   = "name"
#   #   values = ["WIN2016-AYX-*"]
#   # }

#   filter {
#     name   = "root-device-type"
#     values = ["ebs"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
# }


resource "aws_instance" "server" {
  ami                      = "ami-0aaada7cbb0d829fc" # data.aws_ami.ayx_ami.id
  instance_type            = var.AWS_INSTANCE
  vpc_security_group_ids  = [module.networking.security_group_id_out]
  subnet_id               = module.networking.subnet_id_out

  ## Use this count key to determine how many servers you want to create.
  count                   = 1
  key_name                = var.KEY_NAME
  tags = {
    # Name                  = "Server-Cloud"
    Name = "Ayx-Server-Beta-${count.index}"
  }

  root_block_device {
    volume_size           = var.VOLUME_SIZE
    volume_type           = var.VOLUME_TYPE
    delete_on_termination = true
  }

  get_password_data = false # Set to false due to error in creation

  # provisioner "remote-exec" {
  #   connection {
  #     host = coalesce(self.public_ip, self.private_ip)
  #     type = "winrm"

  #     ## Need to provide your own .pem key that can be created in AWS or on your machine for each provisioned EC2.
  #     # password = rsadecrypt(self.password_data, "${data.aws_s3_bucket_object.secret_key.body}")
  #     password = rsadecrypt(self.password_data, "${data.aws_ssm_parameter.ssh.value}")
  #   }
  #   inline = [
  #     "powershell -ExecutionPolicy Unrestricted C:\\Users\\Administrator\\Desktop\\installserver.ps1 -Schedule",
  #   ]
  # }

  # provisioner "local-exec" {
  #   command = "echo ${self.public_ip} >> ../public_ips.txt"
  # }
}

# resource "tfe_organization" "alt-beta" {
#   name  = "The-Information-Lab"
#   email = "paul.houghton@theinformationlab.co.uk"
# }

# resource "tfe_workspace" "alt-beta" {
#   name         = "The-Information-Lab"
#   organization = "${tfe_organization.alt-beta.id}"
# }

# resource "tfe_variable" "alt-beta" {
#   key          = "ALLACCESSIPS"
#   value        = ["0.0.0.0/0"]
#   category     = "terraform"
#   workspace_id = "${tfe_workspace.alt-beta.id}"
#   description  = "Public access IP Addresses"
# }