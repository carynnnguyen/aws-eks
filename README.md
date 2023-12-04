# Terraform Amazon Elastic Kubernetes Service (EKS)

This repository contains Terraform code for deploying an AWS EKS cluster.

## Contents

- [Requirements](#requirements)
- [Providers](#providers)
- [Created Resources](#what-resources-are-created)
- [Configuration](#configuration)
- [Usage Instructions](#how-to-use)
    - [IAM Requirements](#iam)
    - [Terraform Commands](#terraform)
    - [Setting up kubectl](#setup-kubectl)
    - [Authorizing Users](#authorize-users-to-access-the-cluster)
    - [Cleanup](#cleaning-up)

## Requirements

| Name                                   | Version  |
|----------------------------------------|----------|
| [terraform](https://www.terraform.io/) | >= 1.0.0 |

## Providers

| Name                                                                  | Version   |
|-----------------------------------------------------------------------|-----------|
| [aws](https://registry.terraform.io/providers/hashicorp/aws/latest)   | >= 4.61.0 |
| [http](https://registry.terraform.io/providers/hashicorp/http/latest) | >= 3.2.1  |

## What resources are created

1. Virtual Private Cloud (VPC)
2. Internet Gateway (IGW)
3. Public and Private Subnets
4. Security Groups, Route Tables, and Route Table Associations
5. IAM Roles, Instance Profiles, and Policies
6. EKS Cluster
7. EKS Managed Node Group
8. Autoscaling Group and Launch Configuration
9. Worker Nodes in Private Subnet
10. Bastion Host for SSH Access
11. S3 Bucket for Flink High Availability
12. ConfigMap for Node Registration with EKS
13. KUBECONFIG File for kubectl Authentication

## Configuration

Configure the deployment with these input variables:

| Name                         | Description                             | Default                                                               |
|------------------------------|-----------------------------------------|-----------------------------------------------------------------------|
| `cluster_name`               | The name of your EKS Cluster            | `eks-cluster`                                                         |
| `aws_region`                 | The AWS Region to deploy EKS            | `eu-west-1`                                                           |
| `availability_zones`         | AWS Availability Zones                  | `["eu-west-1a", "eu-west-1b", "eu-west-1c"]`                          |
| `k8s_version`                | The desired K8s version to launch       | `1.27`                                                                |
| `node_instance_type`         | Worker Node EC2 instance type           | `t3.large`                                                            |
| `root_block_size`            | Size of the root EBS block device       | `10`                                                                  |
| `desired_capacity`           | Autoscaling Desired node capacity       | `3`                                                                   |
| `max_size`                   | Autoscaling Maximum node capacity       | `4`                                                                   |
| `min_size`                   | Autoscaling Minimum node capacity       | `1` <br/>                                                             |
| `node_instance_type`         | Worker Node EC2 instance type           | `t3.medium`                                                           |
| `sumo_node_desired_capacity` | Autoscaling Desired sumo  node capacity | `1`                                                                   |
| `sumo_node_max_size`         | Autoscaling Maximum sumo node capacity  | `1`                                                                   |
| `sumo_node_min_size`         | Autoscaling Minimum sumo  node capacity | `1`                                                                   |
| `vpc_subnet_cidr`            | Subnet CIDR                             | `10.0.0.0/16`                                                         |
| `private_subnet_cidr`        | Private Subnet CIDR                     | `["10.0.0.0/19", "10.0.32.0/19"]`                                     |
| `public_subnet_cidr`         | Public Subnet CIDR                      | `["10.0.128.0/20", "10.0.144.0/20"]`                                  |
| `db_subnet_cidr`             | DB/Spare Subnet CIDR                    | `["10.0.192.0/21", "10.0.200.0/21"]`                                  |
| `eks_cw_logging`             | EKS Logging Components                  | `["api", "audit", "authenticator", "controllerManager", "scheduler"]` |
| `ec2_key_public_key`         | EC2 Key Pair for bastion and nodes      |                                                                       |
| `s3_bucket_name`             | S3 Bucket Name                          | `bucket`                                                    |

*For the complete list of variables, refer to the configuration section.*

## How to use

Refer to the [examples](example) for complete `.tfvars` file references.

### IAM

Ensure AWS credentials are linked to a user with these IAM policies:

- `IAMFullAccess`
- `AmazonEKSClusterPolicy`
- ...

*Additional custom policies are also required. See the IAM section for details.*

### Terraform

Run these commands:

```bash
terraform init
terraform plan
terraform apply

```

> Note: Run the following commands to save the plan state:
>```bash
>terraform plan -out eks-state
>```

Currently, the terraform state is stored in the
in [CCE State Bucket](https://s3.console.aws.amazon.com/s3/buckets/cce-state?region=eu-west-1&tab=objects) in S3

````bash
aws s3 cp terraform.tfstate s3://cce-state/<cluster-name>/
````

### Setup kubectl

Setup your `KUBECONFIG`

```bash
terraform output kubeconfig > ~/.kube/eks-cluster
export KUBECONFIG=~/.kube/eks-cluster
```
Or
```bash
aws eks update-kubeconfig --region eu-west-1 --name <cluster-name>
```

### Authorize users to access the cluster

Initially, only the system that deployed the cluster will be able to access the cluster. To authorize other users for
accessing the cluster, `aws-auth` config needs to be modified by using the steps given below:

* Open the aws-auth file in the edit mode on the machine that has been used to deploy EKS cluster:

```bash
kubectl edit -n kube-system configmap/aws-auth
or
kubectl get configmap aws-auth -n kube-system -o yaml > aws-auth.yaml
```

* Add the following configuration in that file by changing the placeholders:

```yaml

mapUsers: |
  - userarn: arn:aws:iam::111122223333:user/<username>
    username: <username>
    groups:
      - system:masters
```

So, the final configuration would look like this:

```yaml
apiVersion: v1
data:
  mapRoles: |
    - rolearn: arn:aws:iam::555555555555:role/devel-worker-nodes-NodeInstanceRole-74RF4UBDUKL6
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
  mapUsers: |
    - userarn: arn:aws:iam::111122223333:user/<username>
      username: <username>
      groups:
        - system:masters
```

* Once the user map is added in the configuration we need to create cluster role binding for that user:

```bash
kubectl create clusterrolebinding ops-user-cluster-admin-binding-<username> --clusterrole=cluster-admin --user=<username>
```

> Note: Replace the placeholder with proper values

### Cleaning up

You can destroy this cluster entirely by running:

```bash
terraform plan -destroy
terraform destroy  --force
```

### Note

#### Create StorageClass for GP3

1. You can do this by creating a YAML file (let's name it `gp3-storageclass.yaml`) with the following content:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gp3
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp3
reclaimPolicy: Delete
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
```

2. Then, apply this configuration with kubectl:

```bash
kubectl apply -f gp3-storageclass.yaml
```

3. Set GP3 as the Default StorageClass:
   You'll want to make sure that gp3 is set as the default storage class. This involves two steps:

- Remove the default annotation from the existing gp2 storage class:

```bash

kubectl patch storageclass gp2 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
```

- Set gp3 as the new default:

```bash
kubectl patch storageclass gp3 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

4. Verify the Changes:

```bash
 kubectl get storageclass
```
