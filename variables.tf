variable "cidr"{
    type=string
    default={}

}

variable "common_tags"{
    default= {}
}

variable "project_name" {
    type = string
}

variable "environment" {
    type = string
}