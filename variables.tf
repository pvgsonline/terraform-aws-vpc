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