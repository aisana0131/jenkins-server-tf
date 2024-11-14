data "aws_route53_zone" "hosted_zone" {
    name = "aisanaproperties.com"
    private_zone = false
}