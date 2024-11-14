locals {
  common_tags = {
    Team             = var.team
    Env              = var.env
    Project          = var.project
    Application_tier = var.application_tier
    ManagedBy        = var.ManagedBy
    Owner            = var.owner
  }
  purpose = "testing" // string
  count   = 4         // number
  isProd  = true      //boolean
  name    = "aws-${var.team}-${var.env}-${var.project}-${var.application_tier}-%s"

}