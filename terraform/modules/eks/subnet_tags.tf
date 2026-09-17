resource "aws_ec2_tag" "public_elb"{
	for_each = {for idx, id in var.public_subnet_ids : idx => id}

	resource_id = each.value
	key = "kubernetes.io/role/elb"
	value = "1"
}

resource "aws_ec2_tag" "private_elb"{
	for_each = {for idx, id in var.private_subnet_ids : idx => id}

	resource_id = each.value
	key = "kubernetes.io/role/internal-elb"
	value = "1"
}
