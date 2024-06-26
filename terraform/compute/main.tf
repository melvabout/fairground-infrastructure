terraform {
  backend "s3" {}
}

resource "aws_key_pair" "fairground" {
  key_name   = "server-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCqLyC5tLgtgwzIGvaiAUeFMFcI64fOTwoAX1YuGd9cvdNzMxeUcFv1J3lobj8Ypa2s+EbtuCh+DdHsDBbu+JtGE+Tf2oG3ZPhw1HLpU+M+nBqZjQmuc53P+8W5U7EV3ZXb4/UOpiaX2n/tzzPjs5CPcprhv6tnB9p6WB5QVVjsQwdgGC16oFH8+417eaCfvDZ019bif4eFBzw94EbmyJakOiqT3Yn0zwvFkjOlD1tQ7zcIu2UxYqSzXk2O0IMjm5BU/8biIxJV5YMTMwZAHNa6hq8zt/ZJh+rnWQspbfYBp4Ju3mKu663ITvFHhfO5JoJvxI2mg3cIRXHFX9N4g5r2m1OiTZvpy/+P7evemhahH+hwP/ZlXoFnxxwavDazld+SExdPnt97+UlCHHjqSyxHJP6O6tUd4H9twoR0yhCvYioDyXEG4zxHq4SSH3RmfC/aKbdOGaaT1fkfG8Ad6hdROnXIeXvhyq8KDRQtS8bZbKjoKoa9lxKktPL11wU+2864ZNnaj+4Nroz9/wgeqBDgFoMRXw/3AFB1Q8DMYvOh9/y5j7lSDIiaoWVevQ0CKmSbAVlgB0vEbHD3fFz2gj1vfissPlA75pEHsvHNoappcs/Nt0XKY7r8iUCzEZDo0n66bUGzgH7fGWSdIM1rl1hxqtbKbyRmbcHdIn+mwA46rQ=="
}

resource "aws_iam_role" "fairground" {
  name               = "fairground-server"
  assume_role_policy = data.aws_iam_policy_document.server.json
}

resource "aws_iam_policy" "fairground" {
  policy = data.aws_iam_policy_document.server_policy.json
  name   = "server_iam_policy"
}

resource "aws_iam_role_policy_attachment" "fairground" {
  role       = aws_iam_role.fairground.name
  policy_arn = aws_iam_policy.fairground.arn
}

resource "aws_iam_role_policy_attachment" "ssm_fairground" {
  role       = aws_iam_role.fairground.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "fairground" {
  name = "server_profile"
  role = aws_iam_role.fairground.name
}

resource "aws_launch_template" "server" {

  image_id      = var.server_image_id
  instance_type = "t2.micro"
  user_data     = filebase64("files/server_user_data.sh")
  key_name      = aws_key_pair.fairground.key_name
  private_dns_name_options {
    enable_resource_name_dns_a_record = true
  }

  metadata_options {
    http_tokens = "required"
  }

  iam_instance_profile {
    arn = aws_iam_instance_profile.fairground.arn
  }

  vpc_security_group_ids = [aws_security_group.fairground.id]

}

resource "aws_security_group" "fairground" {
  name   = "fairground"
  vpc_id = var.vpc_id

  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.this.cidr_block]
  }

  ingress {
    from_port   = "49152"
    to_port     = "65535"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_autoscaling_group" "server" {
  min_size            = 1
  max_size            = 1
  desired_capacity    = 1
  vpc_zone_identifier = [var.subnet_ids[0]]

  launch_template {
    id      = aws_launch_template.server.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "fairground-server"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8"
    value               = "server"
    propagate_at_launch = true
  }
  tag {
    key                 = "application"
    value               = "fairground"
    propagate_at_launch = true
  }

}

resource "aws_autoscaling_group" "node" {
  depends_on = [aws_autoscaling_group.server]

  for_each = var.node_image_ids

  min_size            = 1
  max_size            = 1
  desired_capacity    = 1
  vpc_zone_identifier = [var.subnet_ids[0]]

  launch_template {
    id      = aws_launch_template.node[each.key].id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "fairground-${each.key}"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8"
    value               = each.key
    propagate_at_launch = true
  }
  tag {
    key                 = "application"
    value               = "fairground"
    propagate_at_launch = true
  }

}

resource "aws_launch_template" "node" {

  for_each = var.node_image_ids

  image_id      = each.value
  instance_type = "t2.micro"
  user_data     = filebase64("files/node_user_data.sh")
  key_name      = aws_key_pair.fairground.key_name
  private_dns_name_options {
    enable_resource_name_dns_a_record = true
  }

  metadata_options {
    http_tokens = "required"
  }

  iam_instance_profile {
    arn = aws_iam_instance_profile.fairground.arn
  }

  vpc_security_group_ids = [aws_security_group.fairground.id]

}

resource "aws_iam_role" "populate_hosts" {
  name               = "populate-hosts"
  assume_role_policy = data.aws_iam_policy_document.populate_hosts.json
}

resource "aws_iam_policy" "populate_hosts" {
  name   = "populate_hosts_policy"
  policy = data.aws_iam_policy_document.populate_hosts_policy.json
}

resource "aws_iam_role_policy_attachment" "populate_hosts" {
  role       = aws_iam_role.populate_hosts.name
  policy_arn = aws_iam_policy.populate_hosts.arn
}

resource "aws_iam_role_policy_attachment" "populate_hosts_execution" {
  role       = aws_iam_role.populate_hosts.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaExecute"
}

resource "aws_lambda_function" "populate_hosts" {
  count         = signum(length(var.s3_key))
  role          = aws_iam_role.populate_hosts.arn
  function_name = "populate-hosts"
  runtime       = "python3.11"
  s3_bucket     = var.s3_bucket
  s3_key        = var.s3_key
  handler       = "handler.main"
  timeout       = 10
}

resource "aws_sns_topic_subscription" "populate_hosts" {
  count     = signum(length(var.s3_key))
  topic_arn = var.sns_topic_arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.populate_hosts[0].arn
}

resource "aws_lambda_permission" "populate_hosts_via_sns" {
  count         = signum(length(var.s3_key))
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.populate_hosts[0].function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.sns_topic_arn
}