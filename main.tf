locals {
  depersonalization_name = "golden-ami-test"
}

resource "aws_instance" "depersonalization" {
  instance_type        = "c6i.xlarge"
  ami                  = "ami-0a3075c7586c00b8d" // flatiron ubuntu 22.04
  iam_instance_profile = aws_iam_instance_profile.depersonalization.name
  key_name      = aws_key_pair.ssh_key.key_name

  subnet_id = data.aws_subnet.outpost_subnet.id
  vpc_security_group_ids = [
    "sg-0f6190803fa290d03"
  ]

  root_block_device {
    encrypted   = true
    volume_size = 237 // c6id has 237GB storage
  }

  user_data     = <<END
                    #cloud-config
                      system_info:
                        default_user:
                          name: bingwang
                          gecos: null
                  END

  tags = {
    Name   = local.depersonalization_name,
  }
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "ssh_key"
  public_key = file("~/.ssh/ssh_key_flatiron.pub")
}

resource "aws_iam_role" "depersonalization" {
  name = local.depersonalization_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_instance_profile" "depersonalization" {
  role = aws_iam_role.depersonalization.id
}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["jp-dev-01"]
  }
}

data "aws_subnet" "outpost_subnet" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = ["jp-dev-01-private-ap-northeast-1a"]
  }
}
