# AWS Load Balancer Controller

AWS Documentation:

https://docs.aws.amazon.com/eks/latest/userguide/lbc-helm.html

# Install

curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.11.0/docs/install/iam_policy.json

```
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json
```

Expected output:

```
{
    "Policy": {
        "PolicyName": "AWSLoadBalancerControllerIAMPolicy",
        "PolicyId": "ANPA6GSNG3KEO74D4SSB7",
        "Arn": "arn:aws:iam::xxxxxxxxx:policy/AWSLoadBalancerControllerIAMPolicy",
        "Path": "/",
        "DefaultVersionId": "v1",
        "AttachmentCount": 0,
        "PermissionsBoundaryUsageCount": 0,
        "IsAttachable": true,
        "CreateDate": "2025-01-02T14:34:24+00:00",
        "UpdateDate": "2025-01-02T14:34:24+00:00"
    }
}
```

Attach the policy

```
eksctl create iamserviceaccount \
  --cluster=eks-demo-v2 \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::xxxxxxxxx:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve
```

Expected output:

```
2025-01-01 20:50:39 [ℹ]  1 iamserviceaccount (kube-system/aws-load-balancer-controller) was included (based on the include/exclude rules)
2025-01-01 20:50:39 [!]  metadata of serviceaccounts that exist in Kubernetes will be updated, as --override-existing-serviceaccounts was set
2025-01-01 20:50:39 [ℹ]  1 task: { 
    2 sequential sub-tasks: { 
        create IAM role for serviceaccount "kube-system/aws-load-balancer-controller",
        create serviceaccount "kube-system/aws-load-balancer-controller",
    } }2025-01-01 20:50:39 [ℹ]  building iamserviceaccount stack "eksctl-eks-demo-addon-iamserviceaccount-kube-system-aws-load-balancer-controller"
2025-01-01 20:50:39 [ℹ]  deploying stack "eksctl-eks-demo-addon-iamserviceaccount-kube-system-aws-load-balancer-controller"
2025-01-01 20:50:39 [ℹ]  waiting for CloudFormation stack "eksctl-eks-demo-addon-iamserviceaccount-kube-system-aws-load-balancer-controller"
2025-01-01 20:51:09 [ℹ]  waiting for CloudFormation stack "eksctl-eks-demo-addon-iamserviceaccount-kube-system-aws-load-balancer-controller"
2025-01-01 20:51:09 [ℹ]  created serviceaccount "kube-system/aws-load-balancer-controller"
```

Note: This creates a CloudFormation stack. If you wish to un-install/re-install delete the stack first.

To delete the iamserviceaccount:

```
eksctl delete iamserviceaccount --name aws-load-balancer-controller --cluster eks-demo
```

Install AWS Load Balancer Controller

```
helm repo add eks https://aws.github.io/eks-charts

helm repo update eks

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=eks-demo-v2 \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
  
  
helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller \
    --set clusterName=eks-demo \
    --set serviceAccount.create=false \
    --set region=us-east-1 \
    --set vpcId=vpc-xxxxxxxxx \
    --set serviceAccount.name=aws-load-balancer-controller \
    -n kube-system  
```

Expected output:

NAME: aws-load-balancer-controller
LAST DEPLOYED: Thu Jan  2 14:40:34 2025
NAMESPACE: kube-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
AWS Load Balancer controller installed!


Verify controller is installed:

```
kubectl get deployment -n kube-system aws-load-balancer-controller
```

Expected output:

```
NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
aws-load-balancer-controller   2/2     2            2           5m20s
```

Uninstall load balancer:

```
helm delete aws-load-balancer-controller -n kube-system
```

# Verify deployment

```
kubectl get deployment -n kube-system aws-load-balancer-controller
```

Expected output:

```
NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
aws-load-balancer-controller   2/2     2            2           45s
```

Verify aws pods running:

```
kubectl get pods -n kube-system
```

Expected output:

```
ubuntu@ip-172-31-88-153:~$ kubectl get pods -n kube-system
NAME                                            READY   STATUS    RESTARTS   AGE
aws-load-balancer-controller-5c7dc76d68-fqtwh   1/1     Running   0          94s
aws-load-balancer-controller-5c7dc76d68-q5cct   1/1     Running   0          94s
```

Create deployment and service

```
kubectl apply -f deployment.yaml
```

Apply Ingres Class

```
kubectl apply -f ingress-class.yaml
```

Verify it is running

```
kubectl get ingressclass/ingres-class
```

Expected output:

```
NAME           CONTROLLER            PARAMETERS   AGE
ingres-class   ingress.k8s.aws/alb   <none>       46s
```

Apply Ingress rules (This will create the AWS ALB)

```
kubectl apply -f ingress-rules.yaml
```

The load balancer should launch, and you will be able to access the applications via:
http://load-balancer-url/nginx

Note: The example above in the deployment will be looking for a directory called nginx so
you will need to modify the document root a little. 

You can also adjust the path in the ingress-rules.yaml file.

```
kubectl exec -it <pod-name> -- /bin/bash
cd /usr/share/nginx/html/
mkdir nginx
cp index.html nginx/
```
Now when you visit http://load-balancer-dns-name/nginx you should see the following:

Welcome to nginx!
