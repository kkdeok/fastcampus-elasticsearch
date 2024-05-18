locals {
  # TODO: 최소 2 개 이상의 SUBNET 아이디를 입력하세요.
  subnet_ids   = []
}

// elasticsearch master seed node setting
module "master_seed" {
  source = "../../modules/elastic-node"

  cluster_name = "fastcampus-elasticsearch-ch02"
  name                = "master-seed-node"
  role                = "master"
  is_seed_master_node = true
  cnt                 = 1

  sg_id = module.elastic_sg.elastic_sg_id
  instance_profile_name = module.elastic_role.elastic_instance_profile_name
  subnet_ids = local.subnet_ids
}

// elasticsearch master eligible node setting
module "master_eligible" {
  source = "../../modules/elastic-node"

  cluster_name = "fastcampus-elasticsearch-ch02"
  name = "master-eligible-node"
  role = "master"
  cnt  = 2

  sg_id = module.elastic_sg.elastic_sg_id
  instance_profile_name = module.elastic_role.elastic_instance_profile_name
  subnet_ids = local.subnet_ids

  depends_on = [
    module.master_seed
  ]
}

// elasticsearch data node setting
module "data" {
  source = "../../modules/elastic-node"

  cluster_name = "fastcampus-elasticsearch-ch02"
  name = "data-node"
  role = "data"
  cnt  = 3

  sg_id = module.elastic_sg.elastic_sg_id
  instance_profile_name = module.elastic_role.elastic_instance_profile_name
  subnet_ids = local.subnet_ids

  depends_on = [
    module.master_seed,
    module.master_eligible
  ]
}

module "elastic_sg" {
  source = "../../modules/elastic-sg"
}

module "elastic_role" {
  source = "../../modules/elastic-role"
}