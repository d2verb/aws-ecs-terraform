# VPC and Subnets
resource "aws_vpc" "learn_ecs" {
  cidr_block = "10.2.0.0/16"

  tags = {
    Name = "learn-ecs"
  }
}

resource "aws_subnet" "public_1a" {
  vpc_id            = aws_vpc.learn_ecs.id
  availability_zone = "ap-northeast-1a"
  cidr_block        = "10.2.1.0/24"

  tags = {
    Name = "learn-ecs-public-1a"
  }
}

resource "aws_subnet" "public_1c" {
  vpc_id            = aws_vpc.learn_ecs.id
  availability_zone = "ap-northeast-1c"
  cidr_block        = "10.2.2.0/24"

  tags = {
    Name = "learn-ecs-public-1c"
  }
}

resource "aws_subnet" "protected_1a" {
  vpc_id            = aws_vpc.learn_ecs.id
  availability_zone = "ap-northeast-1c"
  cidr_block        = "10.2.10.0/24"

  tags = {
    Name = "learn-ecs-protected-1a"
  }
}

resource "aws_subnet" "protected_1c" {
  vpc_id            = aws_vpc.learn_ecs.id
  availability_zone = "ap-northeast-1a"
  cidr_block        = "10.2.20.0/24"

  tags = {
    Name = "learn-ecs-protected-1c"
  }
}

# NAT Gateway
resource "aws_eip" "learn_ecs_nat_1a" {
  vpc = true
  tags = {
    Name = "learn-ecs-nat-1a-eip"
  }
}

resource "aws_nat_gateway" "learn_ecs_nat_1a" {
  subnet_id     = aws_subnet.public_1a.id
  allocation_id = aws_eip.learn_ecs_nat_1a.id
  tags = {
    Name = "learn-ecs-nat-1a"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "learn_ecs" {
  vpc_id = aws_vpc.learn_ecs.id

  tags = {
    Name = "learn-ecs-ig"
  }
}

# Route tables
## For Internet Gateway
resource "aws_route_table" "learn_ecs_public" {
  vpc_id = aws_vpc.learn_ecs.id

  tags = {
    Name = "learn-ecs-public-rt"
  }
}

resource "aws_route" "learn_ecs_public" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.learn_ecs_public.id
  gateway_id             = aws_internet_gateway.learn_ecs.id
}

resource "aws_route_table_association" "learn_ecs_public_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.learn_ecs_public.id
}

resource "aws_route_table_association" "learn_ecs_public_1c" {
  subnet_id      = aws_subnet.public_1c.id
  route_table_id = aws_route_table.learn_ecs_public.id
}

## For NAT Gateway
resource "aws_route_table" "learn_ecs_protected" {
  vpc_id = aws_vpc.learn_ecs.id

  tags = {
    Name = "learn-ecs-protected-rt"
  }
}

resource "aws_route" "learn_ecs_protected" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.learn_ecs_protected.id
  nat_gateway_id         = aws_nat_gateway.learn_ecs_nat_1a.id
}

resource "aws_route_table_association" "learn_ecs_protected_1a" {
  subnet_id      = aws_subnet.protected_1a.id
  route_table_id = aws_route_table.learn_ecs_protected.id
}

resource "aws_route_table_association" "learn_ecs_protected_1c" {
  subnet_id      = aws_subnet.protected_1c.id
  route_table_id = aws_route_table.learn_ecs_protected.id
}