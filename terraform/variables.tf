variable "aws_region" {
    description = "AWS Region"
    type = string
    default = "ap-south-1"
}

variable "cluster_name" {
    description = "EKS Cluster Name"
    type = string
    default = "eks-gitops-observability"
}

variable "cluster_version" {
    description = "EKS Cluster Version"
    type = string
    default = "1.29"
}

variable "vpc_cider" {
    description = "VPC CIDR Block"
    type = string
    default = "10.0.0.0/16"
}

variable "node_instance_type" {
    description = "EC2 Instance type for worker nodes "
    type = string
    default = "t2.small"
}

variable "node_desired_count" {
    type = number
    default = 2
}

variable "node_min_count" {
    type = number
    default = 1
}

variable "node_max_count" {
    type = number
    default = 3
}
