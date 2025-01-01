# AWS Load Balancer Controller

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
        "PolicyId": "ANPAS252WHXQVPCNBYRXY",
        "Arn": "arn:aws:iam::195275668961:policy/AWSLoadBalancerControllerIAMPolicy",
        "Path": "/",
        "DefaultVersionId": "v1",
        "AttachmentCount": 0,
        "PermissionsBoundaryUsageCount": 0,
        "IsAttachable": true,
        "CreateDate": "2025-01-01T13:38:13+00:00",
        "UpdateDate": "2025-01-01T13:38:13+00:00"
    }
}
```

Attach the policy

```
eksctl create iamserviceaccount \
  --cluster=eks-demo \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::195275668961:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve
```

Install AWS Load Balancer Controller

```
helm repo add eks https://aws.github.io/eks-charts

helm repo update eks

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=eks-demo \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
```

Verify controller is installed:

```
kubectl get deployment -n kube-system aws-load-balancer-controller
```

Expected output:

```
NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
aws-load-balancer-controller   0/2     0            0           15m
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

Create deployment and exposing applications:

```
kubectl create deployment web --image=gcr.io/google-samples/hello-app:1.0
kubectl create deployment web2 --image=gcr.io/google-samples/hello-app:2.0
```

Expose the deployments:

```
kubectl expose deployment web --type=NodePort --port=8080
kubectl expose deployment web2 --port=8080 --type=NodePort
```

Note: This step is failing could be some conflict on the account from past tries...

```
Error from server (InternalError): Internal error occurred: failed calling webhook "mservice.elbv2.k8s.aws": failed to call webhook: Post "https://aws-load-balancer-webhook-service.kube-system.svc:443/mutate-v1-service?timeout=10s": no endpoints available for service "aws-load-balancer-webhook-service"
```

Apply Ingress rules

```
kubectl apply -f ingress-rules.yaml
```

The load balancer should launch and you will be able to access the applications via:
http://load-balancer-url/v1
http://load-balancer-url/v2
