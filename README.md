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
aws ec2 create-volume --size 10 --region us-east-1 --availability-zone us-east-1b --volume-type gp2
kubectl create -f persistentvolume.yaml
kubectl get pv
```

Create a persistent volume claim

```
kubectl create -f peristentvolumeclaim.yaml
kubectl get pvc
kubectl events
```

The event might indicate the pvc is waiting to be consumed?

```
14s (x3 over 40s)   Normal    WaitForFirstConsumer      PersistentVolumeClaim/ebs-pvc     waiting for first consumer to be created before binding
```

Create a POD and attach the pvc volume

```
kubectl create -f pod-nginx.yaml
kubectl get pvc
```

The PVC will now show it has been bound.

It is important that the volume is created in the same availability zone as the nodes or the volume will never
attach to the pod.

```
  Warning  FailedAttachVolume  118s                   attachdetach-controller  AttachVolume.Attach failed for volume "ebs-pv" : rpc error: code = Internal desc = Could not attach volume "vol-0f7fe1b48c276129f" to node "i-043ec2fb8a4991e6c": could not attach volume "vol-0f7fe1b48c276129f" to node "i-043ec2fb8a4991e6c": operation error EC2: AttachVolume, https response error StatusCode: 400, RequestID: d20f2f5f-24b3-48c4-a484-36cb6816fd2f, api error InvalidVolume.ZoneMismatch: The volume 'vol-0f7fe1b48c276129f' is not in the same availability zone as instance 'i-043ec2fb8a4991e6c'
```

Create a new volume in the correct AZ then delete the pod, pvc and pv. Update the PV with the new vol
and re-create the pv, pvc and pod. The storage will now attach to the pod.

```
/dev/nvme1n1    9.8G   28K  9.8G   1% /data
```




