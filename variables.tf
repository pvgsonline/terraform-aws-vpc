variable "cidr"{
    type=string 

}

variable "common_tags"{
    default = {}
}

variable "project_name" {
    type = string
}

variable "environment" {
    type = string
}

variable "enable_dns_hostnames"{
    default =  true
}

variable "public_subnet_cidr"{
    type=list
    validation{
        condition = length(var.public_subnet_cidr) == 2
        error_message = "please provide 2 valid public subnet cider"
    }

}

variable "private_subnet_cidr"{
    type=list
    validation{
        condition = length(var.private_subnet_cidr) == 2
        error_message = "please provide 2 valid public subnet cider"
    }

}

variable "database_subnet_cidr"{
    type=list
    validation{
        condition = length(var.database_subnet_cidr) == 2
        error_message = "please provide 2 valid public subnet cider"
    }

}

variable "is_peering_required" {
    type = bool
    default = false
}