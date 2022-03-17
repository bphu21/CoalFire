resource "aws_vpc" "Main" {
 cidr_block = var.main_vpc_cidr 
 instance_tenancy = "default"
}

resource "aws_internet_gateway" "IGW" {
 vpc_id =  aws_vpc.Main.id
}

resource "aws_subnet" "publicsubnets" {
 vpc_id =  aws_vpc.Main.id 
 cidr_block = "${var.public_subnets}"
}

resource "aws_subnet" "publicsubnets2" {
  vpc_id =  aws_vpc.Main.id
  cidr_block = "${var.public_subnets_2}"
}

resource "aws_subnet" "privatesubnets" {
  vpc_id =  aws_vpc.Main.id
  cidr_block = "${var.private_subnets}"
}

resource "aws_subnet" "privatesubnets2" {
 vpc_id =  aws_vpc.Main.id
 cidr_block = "${var.private_subnets_2}"
}

resource "aws_route_table" "PublicRT" {
   vpc_id =  aws_vpc.Main.id
        route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.IGW.id
    }
}

resource "aws_route_table" "PrivateRT" {
   vpc_id = aws_vpc.Main.id
   route {
   cidr_block = "0.0.0.0/0"
   nat_gateway_id = aws_nat_gateway.NATgw.id
   }
 }
 
resource "aws_route_table_association" "PublicRTassociation" {
    subnet_id = aws_subnet.publicsubnets.id
    route_table_id = aws_route_table.PublicRT.id
 }

resource "aws_route_table_association" "PublicRTassociation2" {
    subnet_id = aws_subnet.publicsubnets2.id
    route_table_id = aws_route_table.PublicRT.id
 }

resource "aws_route_table_association" "PrivateRTassociation" {
    subnet_id = aws_subnet.privatesubnets.id
    route_table_id = aws_route_table.PrivateRT.id
 }

resource "aws_route_table_association" "PrivateRTassociation2" {
    subnet_id = aws_subnet.privatesubnets2.id
    route_table_id = aws_route_table.PrivateRT.id
 }

resource "aws_eip" "nateIP" {
   vpc   = true
 }

resource "aws_nat_gateway" "NATgw" {
   allocation_id = aws_eip.nateIP.id
   subnet_id = aws_subnet.publicsubnets.id
 }


resource "aws_security_group" "web_sg" {
  name   = "HTTP and SSH"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web_instance" {
  ami           = "ami-ObOaf3577fe5e3532"
  instance_type = "t2.nano"
  key_name      = "briankeys"

  subnet_id                   = aws_subnet.publicsubnets2.id

vpc_security_group_ids      = [aws_security_group.web_sg.id]

  associate_public_ip_address = true
}