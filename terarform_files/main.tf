//VPC creation
resource "aws_vpc" "vpc1" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = "true" #gives you an internal domain name
    enable_dns_hostnames = "true" #gives you an internal host name
    enable_classiclink = "false"
    instance_tenancy = "default"   
    
    tags {
        Name = "vpc1"
    }
}
//subnet creation

resource "aws_subnet" "subnet-public-1" {
    vpc_id = "${aws_vpc.vpc1.id}"
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = "true" //it makes this a public subnet
    availability_zone = "eu-west-2a"
    tags {
        Name = "subnet-public-1"
    }
    depends_on = []
}

resource "aws_subnet" "subnet-public-2" {
    vpc_id = "${aws_vpc.vpc1.id}"
    cidr_block = "10.0.2.0/24"
    map_public_ip_on_launch = "true" //it makes this a public subnet
    availability_zone = "eu-west-2a"
    tags {
        Name = "subnet-public-2"
    }
    depends_on = []
}

resource "aws_subnet" "subnet-private-1" {
    vpc_id = "${aws_vpc.vpc1.id}"
    cidr_block = "10.0.3.0/24"
    map_public_ip_on_launch = "false" //it makes this a public subnet
    availability_zone = "eu-west-2a"
    tags {
        Name = "subnet-private-1"
    }
    depends_on = []
}

resource "aws_subnet" "subnet-private-2" {
    vpc_id = "${aws_vpc.vpc1.id}"
    cidr_block = "10.0.4.0/24"
    map_public_ip_on_launch = "false" //it makes this a public subnet
    availability_zone = "eu-west-2a"
    tags {
        Name = "subnet-private-2"
    }
    depends_on = []
}

//connect vpc to internet

resource "aws_internet_gateway" "igw" {
    vpc_id = "${aws_vpc.vpc1.id}"
    tags {
        Name = "igw"
    }
    depends_on = []
}
//Create a custom route table for public subnet. public subnet can reach to the internet by using this

resource "aws_route_table" "prod-public-crt" {
    vpc_id = "${aws_vpc.vpc1.id}"
    
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0" 
        //CRT uses this IGW to reach internet
        gateway_id = "${aws_internet_gateway.igw.id}" 
    }
    
    tags {
        Name = "public-crt"
    }
    depends_on = []
}

resource "aws_route_table_association" "crta-public-subnet-1"{
    subnet_id = "${aws_subnet.subnet-public-1.id}"
    route_table_id = "${aws_route_table.prod-public-crt.id}"
    depends_on = []
}

resource "aws_route_table_association" "crta-public-subnet-2"{
    subnet_id = "${aws_subnet.subnet-public-2.id}"
    route_table_id = "${aws_route_table.prod-public-crt.id}"
    depends_on = []
}

//private NAT 

resource "aws_nat_gateway" "example" {
  connectivity_type = "private"
  subnet_id         = "${aws_subnet.subnet-private-1.id}"
  depends_on = []
}

resource "aws_nat_gateway" "example2" {
  connectivity_type = "private"
  subnet_id         = "${aws_subnet.subnet-private-2.id}"
  depends_on = []
}


