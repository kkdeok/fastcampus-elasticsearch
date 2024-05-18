data "template_file" "kibana_yml" {
  template = file("${path.module}/kibana.yml")
  vars     = {
    elasticsearch_host = "http://${var.elasticsearch_host}"
    monitoring_elasticsearch_host = "http://${var.monitoring_elasticsearch_host}"
  }
}

data "template_file" "docker_compose_yml" {
  template = file("${path.module}/docker-compose.yml")
  vars     = {
    kibana_image : var.kibana_image
  }
}

data "template_cloudinit_config" "cloudinit" {
  gzip          = true
  base64_encode = true
  part {
    content_type = "text/cloud-config"
    content      = templatefile("${path.module}/cloudinit.yml", {
      kibana_yml : indent(6, data.template_file.kibana_yml.rendered),
      docker_compose_yml : indent(6, data.template_file.docker_compose_yml.rendered),
    })
  }
}

# Launch Template 생성
resource "aws_launch_template" "elastic_launch_template" {
  name_prefix = "kibana-launch-template"  # Launch Template의 이름 접두사를 지정
  description = "Kibana Launch Template"  # Launch Template의 설명을 지정.

  vpc_security_group_ids = [var.sg_id]

  image_id      = var.image_id
  instance_type = var.instance_type  # 인스턴스 유형 지정
  key_name      = var.key_name   # 키페어 이름 지정

  # 볼륨 설정
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 8     # 볼륨 크기를 8GB로 지정
      volume_type = "gp3" # 볼륨 유형을 gp3로 지정
    }
  }

  # IAM 역할 설정
  iam_instance_profile {
    name = var.instance_profile_name
  }

  user_data = data.template_cloudinit_config.cloudinit.rendered

  # 태그 설정 (옵션)
  tag_specifications {
    resource_type = "instance"
    tags          = {
      Name = "kibana-node"
    }
  }
}

resource "aws_autoscaling_group" "asg" {
  name             = "kibana-asg"
  max_size         = var.cnt
  min_size         = var.cnt
  desired_capacity = var.cnt

  launch_template {
    id      = aws_launch_template.elastic_launch_template.id
    version = "$Latest"
  }

  vpc_zone_identifier = var.subnet_ids
  depends_on = [aws_launch_template.elastic_launch_template]
}
