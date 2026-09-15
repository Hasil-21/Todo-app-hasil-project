resource "aws_codestarconnections_connection" "github" {
        name = "${var.name_prefix}-connection"
        provider_type = "GitHub"
}
