// Setup the required ELBs

// Setup Public ELB
resource "aws_lb" "public_elb" {
  name                             = "openshift-public-elb"
  internal                         = false
  load_balancer_type               = "network"
  subnets                          = ["${aws_subnet.public-subnet.id}"]
  //subnets                          = ["${aws_subnet.public.*.id}"]
  //subnets                          = ["${var.public_subnet_ids}"]
  enable_cross_zone_load_balancing = true

  //  Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "OpenShift Public ELB"
    )
  )}"
}

// Get DNS for this ELB (for output)
data "dns_a_record_set" "public_ip_set" {
  host = "${aws_lb.public_elb.dns_name}"
}

// Create Target Groups and health checks
resource "aws_lb_target_group" "http" {
  name                 = "${var.cluster_name}-http"
  port                 = 80
  protocol             = "TCP"
  vpc_id               = "${aws_vpc.openshift.id}"
  deregistration_delay = 180

  health_check {
    interval            = 30
    port                = "traffic-port"
    protocol            = "TCP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_target_group" "https" {
  name                 = "${var.cluster_name}-https"
  port                 = 443
  protocol             = "TCP"
  vpc_id               = "${aws_vpc.openshift.id}"
  deregistration_delay = 180

  health_check {
    interval            = 30
    port                = "traffic-port"
    protocol            = "TCP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

// Create Listeners
resource "aws_lb_listener" "http" {
  load_balancer_arn = "${aws_lb.public_elb.arn}"
  port              = 80
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.http.arn}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = "${aws_lb.public_elb.arn}"
  port              = 443
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.https.arn}"
    type             = "forward"
  }
}

