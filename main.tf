resource "aws_vpc" "week9-vpc" {
  cidr_block = "10.8.0.0/16"
  tags = {
    Name = "week9-vpc"
  }
}

resource "aws_internet_gateway" "week9-gw" {
  vpc_id = aws_vpc.week9-vpc.id

  tags = {
    Name = "week9-gw"
  }
}

resource "aws_subnet" "week9-pub-a" {
  vpc_id                  = aws_vpc.week9-vpc.id
  cidr_block              = "10.8.3.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "week9-pub-a"
  }
}

resource "aws_subnet" "week9-pub-b" {
  vpc_id                  = aws_vpc.week9-vpc.id
  cidr_block              = "10.8.4.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "week9-pub-b"
  }
}

resource "aws_subnet" "week9-pri-a" {
  vpc_id                  = aws_vpc.week9-vpc.id
  cidr_block              = "10.8.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "week9-pri-a"
  }
}

resource "aws_subnet" "week9-pri-b" {
  vpc_id                  = aws_vpc.week9-vpc.id
  cidr_block              = "10.8.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "week9-pri-b"
  }
}

resource "aws_default_route_table" "week9-pub-rt" {
  default_route_table_id  = aws_vpc.week9-vpc.default_route_table_id
  route = [
    {
      cidr_block                 = "0.0.0.0/0"
      gateway_id                 = aws_internet_gateway.week9-gw.id
      destination_prefix_list_id = ""
      egress_only_gateway_id     = ""
      instance_id                = ""
      ipv6_cidr_block            = ""
      nat_gateway_id             = ""
      network_interface_id       = ""
      transit_gateway_id         = ""
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""

    }
  ]
  tags = {
    Name = "week9-pub-rt"
  }
}

resource "aws_route_table_association" "week9-pub-a" {
  subnet_id      = aws_subnet.week9-pub-a.id
  route_table_id = aws_default_route_table.week9-pub-rt.id
}

resource "aws_route_table_association" "week9-pub-b" {
  subnet_id      = aws_subnet.week9-pub-b.id
  route_table_id = aws_default_route_table.week9-pub-rt.id
}

resource "aws_route_table" "week9-pri-rt" {
  vpc_id = aws_vpc.week9-vpc.id
  route  = []
  tags = {
    Name = "week9-pri-rt"
  }
}

resource "aws_route_table_association" "week9-a" {
  subnet_id      = aws_subnet.week9-pri-a.id
  route_table_id = aws_route_table.week9-pri-rt.id
}

resource "aws_route_table_association" "week9-b" {
  subnet_id      = aws_subnet.week9-pri-b.id
  route_table_id = aws_route_table.week9-pri-rt.id
}

resource "aws_security_group" "week9-ssh-sg" {
  name        = "week9-ssh-sg"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.week9-vpc.id

  ingress = [
    {
      description      = "SSH from outside"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress = [
    {
      description      = "Allow all outbound"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  tags = {
    Name = "week9-ssh-sg"
  }
}

resource "aws_security_group" "week9-ssh-pri-sg" {
  name        = "week9-ssh-pri-sg"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.week9-vpc.id

  ingress = [
    {
      description      = "SSH from outside"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = []
      security_groups  = aws_security_group.week9-ssh-sg.id
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress = [
    {
      description      = "Allow all outbound"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  tags = {
    Name = "week9-ssh-pri-sg"
  }
}

resource "aws_instance" "week9-bastion-vm" {
  ami                    = "ami-02e136e904f3da870"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.week9-pub-b.id
  key_name               = "week3-ssh"
  vpc_security_group_ids = [aws_security_group.week9-ssh-sg.id]

  tags = {
    Name = "week9-bastion-vm"
  }
}

resource "aws_iam_instance_profile" "week9-profile" {
  name = "week9-profile"
  role = aws_iam_role.week9-role.name
  tags = {}
}

resource "aws_instance" "week9-worker-vm" {
  ami                    = "ami-02e136e904f3da870"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.week9-pri-b.id
  key_name               = "week3-ssh"
  vpc_security_group_ids = [aws_security_group.week9-ssh-pri-sg.id]
  iam_instance_profile   = aws_iam_instance_profile.week9-profile.name

  tags = {
    Name = "week9-worker-vm"
  }
}

