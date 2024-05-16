terraform {
  backend "s3" {}
}

resource "aws_key_pair" "server" {
  key_name = "server-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCqLyC5tLgtgwzIGvaiAUeFMFcI64fOTwoAX1YuGd9cvdNzMxeUcFv1J3lobj8Ypa2s+EbtuCh+DdHsDBbu+JtGE+Tf2oG3ZPhw1HLpU+M+nBqZjQmuc53P+8W5U7EV3ZXb4/UOpiaX2n/tzzPjs5CPcprhv6tnB9p6WB5QVVjsQwdgGC16oFH8+417eaCfvDZ019bif4eFBzw94EbmyJakOiqT3Yn0zwvFkjOlD1tQ7zcIu2UxYqSzXk2O0IMjm5BU/8biIxJV5YMTMwZAHNa6hq8zt/ZJh+rnWQspbfYBp4Ju3mKu663ITvFHhfO5JoJvxI2mg3cIRXHFX9N4g5r2m1OiTZvpy/+P7evemhahH+hwP/ZlXoFnxxwavDazld+SExdPnt97+UlCHHjqSyxHJP6O6tUd4H9twoR0yhCvYioDyXEG4zxHq4SSH3RmfC/aKbdOGaaT1fkfG8Ad6hdROnXIeXvhyq8KDRQtS8bZbKjoKoa9lxKktPL11wU+2864ZNnaj+4Nroz9/wgeqBDgFoMRXw/3AFB1Q8DMYvOh9/y5j7lSDIiaoWVevQ0CKmSbAVlgB0vEbHD3fFz2gj1vfissPlA75pEHsvHNoappcs/Nt0XKY7r8iUCzEZDo0n66bUGzgH7fGWSdIM1rl1hxqtbKbyRmbcHdIn+mwA46rQ=="
}

resource "aws_iam_role" "server" {
  name               = "fairground-server"
  assume_role_policy = data.aws_iam_policy_document.server.json
}

resource "aws_iam_policy" "server" {
  policy = data.aws_iam_policy_document.server_policy.json
  name = "server_iam_policy"
}

resource "aws_iam_role_policy_attachment" "server" {
  role = aws_iam_role.server.name
  policy_arn = aws_iam_policy.server.arn
}

resource "aws_iam_instance_profile" "server" {
  name = "server_profile"
  role = aws_iam_role.server.name
}

resource "aws_launch_template" "server" {

  image_id = var.server_image_id
  instance_type = "t2.micro"
  user_data = filebase64("files/user_data.sh")
  key_name = aws_key_pair.server.key_name

  metadata_options {
    http_tokens = "required"
  }
  
  iam_instance_profile {
    arn = aws_iam_instance_profile.server.arn
  }
  
}

resource "aws_autoscaling_group" "server" {
  min_size = 1
  max_size = 1
  desired_capacity = 1
  vpc_zone_identifier = var.subnet_ids

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

}