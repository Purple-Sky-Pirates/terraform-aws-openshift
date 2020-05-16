// Route53 DNS Resources

// Grab the Existing Public Hosted Zone Data
data "aws_route53_zone" "public" {
  name = "${var.base_domain}."
}

// Get the ELB Data
data "aws_lb" "public_elb" {
  arn = "${aws_lb.public_elb.arn}"
}

// Add Master/Console Record
// Alias it to the Public ELB
resource "aws_route53_record" "master_public" {
  zone_id = "${data.aws_route53_zone.public.zone_id}"
  name    = "${var.cluster_name}.${var.base_domain}"
  type    = "A"

  alias {
    name                   = "${data.aws_lb.public_elb.dns_name}"
    zone_id                = "${data.aws_lb.public_elb.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "public" {
  zone_id = "${data.aws_route53_zone.public.zone_id}"
  name    = "*.${var.cluster_name}.${var.base_domain}"
  type    = "A"

  alias {
    name                   = "${data.aws_lb.public_elb.dns_name}"
    zone_id                = "${data.aws_lb.public_elb.zone_id}"
    evaluate_target_health = false
  }
}