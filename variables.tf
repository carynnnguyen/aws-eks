# Variables Configuration

variable "cluster_name" {
  default     = "eks-cluster"
  type        = string
  description = "The name of your EKS Cluster"
}

variable "aws_region" {
  default     = "eu-west-1"
  type        = string
  description = "The AWS Region to deploy EKS"
}

variable "availability_zones" {
  default     = ["eu-west-1a", "eu-west-1b"]
  type        = list(string)
  description = "The AWS AZ to deploy EKS"
}

variable "k8s_version" {
  default     = "1.25"
  type        = string
  description = "Required K8s version"
}

variable "kublet_extra_args" {
  default     = ""
  type        = string
  description = "Additional arguments to supply to the node kubelet process"
}

variable "public_kublet_extra_args" {
  default     = ""
  type        = string
  description = "Additional arguments to supply to the public node kubelet process"

}

variable "vpc_subnet_cidr" {
  default     = "10.0.0.0/16"
  type        = string
  description = "The VPC Subnet CIDR"
}

variable "private_subnet_cidr" {
  default     = ["10.0.0.0/19", "10.0.32.0/19"]
  type        = list(string)
  description = "Private Subnet CIDR"
}

variable "public_subnet_cidr" {
  default     = ["10.0.128.0/20", "10.0.144.0/20"]
  type        = list(string)
  description = "Public Subnet CIDR"
}

variable "db_subnet_cidr" {
  default     = ["10.0.192.0/21", "10.0.200.0/21"]
  type        = list(string)
  description = "DB/Spare Subnet CIDR"
}

variable "eks_cw_logging" {
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  type        = list(string)
  description = "Enable EKS CWL for EKS components"
}

variable "node_instance_type" {
  default     = "t3.large"
  type        = string
  description = "Worker Node EC2 instance type"
}

variable "root_block_size" {
  default     = "10"
  type        = string
  description = "Size of the root EBS block device"

}

variable "desired_capacity" {
  default     = "3"
  type        = string
  description = "Autoscaling Desired node capacity"
}

variable "max_size" {
  default     = "4"
  type        = string
  description = "Autoscaling maximum node capacity"
}

variable "min_size" {
  default     = "1"
  type        = string
  description = "Autoscaling Minimum node capacity"
}

variable "ec2_key_public_key" {
  default     = ""
  type        = string
  description = "AWS EC2 public key data"
}


variable "s3_bucket_name" {
  default     = "bucket"
  type        = string
  description = "AWS S3 bucket name"
}

variable "s3_bucket_object" {
  default     = "high-availability"
  type        = string
  description = "AWS S3 bucket object"
}

variable "sumo_node_desired_capacity" {
  default     = "1"
  type        = string
  description = "Autoscaling Desired SumoLogic capacity"
}

variable "sumo_node_max_size" {
  default     = "1"
  type        = string
  description = "Autoscaling maximum SumoLogic capacity"
}

variable "sumo_node_min_size" {
  default     = "1"
  type        = string
  description = "Autoscaling Minimum SumoLogic node capacity"
}

variable "sumo_node_instance_type" {
  default     = "t3.medium"
  type        = string
  description = "Worker Node EC2 instance type"
}
