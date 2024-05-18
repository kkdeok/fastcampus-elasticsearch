locals {
  node_name           = "elastic-${var.name}"
  initial_master_node = var.is_seed_master_node ? "node-${var.role}-instance_id" : ""
}

data "template_file" "elasticsearch_yml" {
  template = file("${path.module}/elasticsearch.yml")
  vars     = {
    cluster_name        = var.cluster_name
    initial_master_node = local.initial_master_node
    role                = var.role
    sg_name             = var.sg_id
  }
}

data "template_file" "metricbeat_yml" {
  template = file("${path.module}/metricbeat.yml")
  vars     = {
    monitoring_elasticsearch_host = var.monitoring_elasticsearch_host
  }
}

data "template_file" "dockerfile" {
  template = file("${path.module}/Dockerfile")
}

data "template_cloudinit_config" "cloudinit" {
  gzip          = true
  base64_encode = true
  part {
    content_type = "text/cloud-config"
    content      = templatefile("${path.module}/cloudinit.yml", {
      elasticsearch_yml : indent(6, data.template_file.elasticsearch_yml.rendered),
      metricbeat_yml : indent(6, data.template_file.metricbeat_yml.rendered),
      dockerfile : indent(6, data.template_file.dockerfile.rendered),
      metricbeat_image : var.metricbeat_image,
    })
  }
}

# Launch Template 생성
resource "aws_launch_template" "elastic_launch_template" {
  name_prefix = "elastic-launch-template"  # Launch Template의 이름 접두사를 지정
  description = "Elastic Launch Template"  # Launch Template의 설명을 지정.

  vpc_security_group_ids = [var.sg_id]

  image_id      = var.image_id
  instance_type = var.instance_type  # 인스턴스 유형 지정
  key_name      = var.key_pair_name   # 키페어 이름 지정

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
      Name    = "${var.cluster_name}-${var.role}"
      Cluster = var.cluster_name
    }
  }
}

resource "aws_autoscaling_group" "asg" {
  name             = "elastic-asg-${var.name}"
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