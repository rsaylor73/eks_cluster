# Creating IAM Policy

curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/install/iam_policy.json

```
aws iam create-policy \
 --policy-name AWSLoadBalancerControllerIAMPolicy \
 --policy-document file://iam_policy.json
```

# Creating Service Account: (replace policy-arm, cluster and region)

```
 eksctl create iamserviceaccount \
 --cluster=eks-demo \
 --region us-east-1 \
 --namespace=kube-system \
 --name=aws-load-balancer-controller \
 --role-name AmazonEKSLoadBalancerControllerRole \
 --attach-policy-arn=<Your-Policy-ARN> \
 --approve
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
