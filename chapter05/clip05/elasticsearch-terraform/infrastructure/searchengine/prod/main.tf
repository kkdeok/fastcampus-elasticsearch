locals {
  default_cluster_name    = "fastcampus-elasticsearch"
  monitoring_cluster_name = "monitoring-elasticsearch"

  metricbeat_image = "docker.elastic.co/beats/metricbeat:8.12.2"

  # TODO: VPC 아이디를 입력하세요.
  vpc_id       = ""
  # TODO: 최소 2 개 이상의 SUBNET 아이디를 입력하세요.
  subnet_ids   = ["", ""]

  elastic_port = "9200"
  monitoring_port = "9200"
}

// elasticsearch master seed node setting
module "master_seed" {
  source = "../../../../../../chapter02/clip07/elasticsearch-terraform/infrastructure/modules/elastic-node"

  cluster_name        = local.default_cluster_name
  name                = "master-seed-node"
  role                = "master"
  is_seed_master_node = true
  cnt                 = 1

  sg_id                 = module.elastic_sg.elastic_sg_id
  instance_profile_name = module.elastic_role.elastic_instance_profile_name
  subnet_ids = local.subnet_ids

  metricbeat_image = local.metricbeat_image
  monitoring_elasticsearch_host = "${module.monitoring_lb.dns_name}:${local.monitoring_port}"
}

// elasticsearch master eligible node setting
module "master_eligible" {
  source = "../../../../../../chapter02/clip07/elasticsearch-terraform/infrastructure/modules/elastic-node"

  cluster_name = local.default_cluster_name
  name         = "master-eligible-node"
  role         = "master"
  cnt          = 2

  sg_id                 = module.elastic_sg.elastic_sg_id
  instance_profile_name = module.elastic_role.elastic_instance_profile_name
  subnet_ids = local.subnet_ids

  metricbeat_image = local.metricbeat_image
  monitoring_elasticsearch_host = "${module.monitoring_lb.dns_name}:${local.monitoring_port}"

  depends_on = [
    module.master_seed
  ]
}

// elasticsearch data node setting
module "data" {
  source = "../../../../../../chapter02/clip07/elasticsearch-terraform/infrastructure/modules/elastic-node"

  cluster_name = local.default_cluster_name
  name         = "data-node"
  role         = "data"
  cnt          = 3

  sg_id                 = module.elastic_sg.elastic_sg_id
  instance_profile_name = module.elastic_role.elastic_instance_profile_name
  subnet_ids = local.subnet_ids

  metricbeat_image = local.metricbeat_image
  monitoring_elasticsearch_host = "${module.monitoring_lb.dns_name}:${local.monitoring_port}"

  depends_on = [
    module.master_seed
  ]
}

module "elastic_lb" {
  source = "../../../../../../chapter02/clip07/elasticsearch-terraform/infrastructure/modules/elastic-lb"

  name         = "elastic-lb"
  cluster_name = local.default_cluster_name
  tg_asg_name  = module.data.asg_name
  sg_ids       = [module.elastic_sg.elastic_sg_id]
  vpc_id       = local.vpc_id
  subnet_ids   = local.subnet_ids

  ports = {
    9200 : 9200
  }
}

module "kibana" {
  source = "../../../../../../chapter02/clip07/elasticsearch-terraform/infrastructure/modules/elastic-kibana"

  elasticsearch_host    = "${module.elastic_lb.dns_name}:${local.elastic_port}"
  monitoring_elasticsearch_host = "${module.monitoring_lb.dns_name}:${local.monitoring_port}"
  sg_id                 = module.elastic_sg.elastic_sg_id
  instance_profile_name = module.elastic_role.elastic_instance_profile_name
  vpc_id                = local.vpc_id
  subnet_ids            = local.subnet_ids
}

module "kibana_lb" {
  source = "../../../../../../chapter02/clip07/elasticsearch-terraform/infrastructure/modules/elastic-lb"

  name         = "kibana-lb"
  cluster_name = local.default_cluster_name
  tg_asg_name  = module.kibana.asg_name
  sg_ids       = [module.elastic_sg.elastic_sg_id]
  vpc_id       = local.vpc_id
  subnet_ids   = local.subnet_ids
  is_internal  = false

  ports = {
    5601 : 5601
  }
}

// monitoring master seed node setting
module "monitoring_seed" {
  source = "../../../../../../chapter02/clip07/elasticsearch-terraform/infrastructure/modules/elastic-node"

  cluster_name        = local.monitoring_cluster_name
  name                = "monitoring-seed-node"
  role                = "master"
  is_seed_master_node = true
  cnt                 = 1

  sg_id                 = module.elastic_sg.elastic_sg_id
  instance_profile_name = module.elastic_role.elastic_instance_profile_name
  subnet_ids            = local.subnet_ids
}

// monitoring data node setting
module "monitoring_data" {
  source = "../../../../../../chapter02/clip07/elasticsearch-terraform/infrastructure/modules/elastic-node"

  cluster_name = local.monitoring_cluster_name
  name         = "monitoring-data-node"
  role         = "data"
  cnt          = 3

  sg_id                 = module.elastic_sg.elastic_sg_id
  instance_profile_name = module.elastic_role.elastic_instance_profile_name
  subnet_ids            = local.subnet_ids

  depends_on = [
    module.monitoring_seed
  ]
}

module "monitoring_lb" {
  source = "../../../../../../chapter02/clip07/elasticsearch-terraform/infrastructure/modules/elastic-lb"

  name         = "monitoring-lb"
  cluster_name = local.monitoring_cluster_name
  tg_asg_name  = module.monitoring_data.asg_name
  sg_ids       = [module.elastic_sg.elastic_sg_id]
  vpc_id       = local.vpc_id
  subnet_ids   = local.subnet_ids

  ports = {
    9200 : 9200
  }
}

module "elastic_sg" {
  source = "../../../../../../chapter02/clip07/elasticsearch-terraform/infrastructure/modules/elastic-sg"
}

module "elastic_role" {
  source = "../../../../../../chapter02/clip07/elasticsearch-terraform/infrastructure/modules/elastic-role"
}