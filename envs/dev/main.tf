module "network" {
  source         = "../../modules/network"
  app_name       = var.app_name
  vpc_cidr_block = "10.0.0.0/16"
  subnet_cidr_blocks = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

module "ecs" {
  source              = "../../modules/ecs"
  app_name            = var.app_name
  vpc_id              = module.network.vpc_id
  private_subnet_a_id = module.network.private_subnet_a_id
  private_subnet_c_id = module.network.private_subnet_c_id
}
