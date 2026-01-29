packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "sparta_app" {
  ami_name      = "tech518-giuseppe-sparta-app"
  instance_type = "t3.micro"
  region        = "eu-west-1"
  source_ami    = "ami-049442a6cf8319180"
  ssh_username  = "ubuntu"
}

build {
  sources = ["source.amazon-ebs.sparta_app"]

  provisioner "shell" {
    script = "./sparta-app.sh"
  }
}
