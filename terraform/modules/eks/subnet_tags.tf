resource "aws_ec2_tags" "public_elb"{
	for_each = toset(var.public_subnet_ids)
	resource_id = each.value
	key = "kubernetes.io/role/elb"
	value = "1"
}

resource "aws_ec2_tags" "private_elb"{
	for_each = toset(var.private_subnet_ids)
	resoruce_id = each.value
	key = "kubernetes.io/role/internal-elb"
	value = "1"
}
