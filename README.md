# Installation

Update the settings in variables.tf including the cluster name and VPC CIDRs.

```
terraform init
terraform plan
terraform apply
```

### Connect with Kubectl

Make sure to replace <output.cluster_name> with the relevant value from your Terraform apply outputs.

Note: make a backup of ~/.kube/config first. Best to remove file before running so you can switch back to
another cluster or minikube.

```
aws eks --region us-east-1 update-kubeconfig --name <output.cluster_name> --profile <profile.name>
```

Verify kubectl is working:

```
kubectl get svc
```

If you get an API error with v1alpha1 in ~/.kube/config change that to v1beta1

### Destroy Cluster

```
terraform plan -destroy
terraform apply -destroy
```

# Persistent Volume

The CSI driver should be installed with the code in this package.

```
kubectl get csidriver ebs.csi.aws.com
```

The default storage class should be gp2

```
kubectl get sc
```

Create a persistent volume from pod-examples/persistentvolume.yaml. Be sure to register an volume first
and update the vol-xxxxx in the yaml file.

```
aws ec2 create-volume --size 10 --region us-east-1 --availability-zone us-east-1a --volume-type gp2
kubectl create -f persistentvolume.yaml
```
