locals {
    base-name = format("%s-%s", var.project_name, var.env)
    short-name = format("%s%s", var.project_name, var.env)

    rg = {    
        name = format("%s-%s", local.base-name, "rg")
        location = var.rg_location
    }
}