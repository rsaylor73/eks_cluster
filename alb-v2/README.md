# Creating IAM Policy

curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/install/iam_policy.json

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
        "PolicyId": "ANPAS252WHXQQF223VOSK",
        "Arn": "arn:aws:iam::195275668961:policy/AWSLoadBalancerControllerIAMPolicy",
        "Path": "/",
        "DefaultVersionId": "v1",
        "AttachmentCount": 0,
        "PermissionsBoundaryUsageCount": 0,
        "IsAttachable": true,
        "CreateDate": "2025-01-01T13:19:51+00:00",
        "UpdateDate": "2025-01-01T13:19:51+00:00"
    }
}

```

# Creating Service Account: (replace policy-arm, cluster and region)

```
 eksctl create iamserviceaccount \
 --cluster=eks-demo \
 --region us-east-1 \
 --namespace=kube-system \
 --name=aws-load-balancer-controller \
 --role-name AmazonEKSLoadBalancerControllerRole \
 --attach-policy-arn=arn:aws:iam::195275668961:policy/AWSLoadBalancerControllerIAMPolicy \
 --override-existing-serviceaccounts \
 --approve
```

Note: This did not appear to work no tasks was reported.

```
2025-01-01 13:23:26 [ℹ]  2 existing iamserviceaccount(s) (kube-system/alb-ingress-controller,kube-system/aws-load-balancer-controller) will be excluded
2025-01-01 13:23:26 [ℹ]  1 iamserviceaccount (kube-system/aws-load-balancer-controller) was excluded (based on the include/exclude rules)
2025-01-01 13:23:26 [!]  serviceaccounts that exist in Kubernetes will be excluded, use --override-existing-serviceaccounts to override
2025-01-01 13:23:26 [ℹ]  no tasks
```

# Installing AWS Load Balancer Controller:

```
helm repo add eks https://aws.github.io/eks-charts

helm repo update eks

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=eks-demo \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
```

# Configuring Ingress Class:

```
kubectl apply -f ingress-class.yaml
```
