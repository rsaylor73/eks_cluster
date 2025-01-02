# AWS Load Balancer Controller

Source:
https://docs.aws.amazon.com/eks/latest/userguide/lbc-helm.html
https://harsh05.medium.com/path-based-routing-with-aws-load-balancer-controller-an-ingress-journey-on-amazon-eks-733d3c6c5adf

Note: Following the guide the AWS Load Balancer was created but the target groups did not
register any nodes and the rules did not get applied.

(img.png)

Some notes on binding the instances to the targets:
https://stackoverflow.com/questions/66526636/eks-nodes-not-registering-in-target-group-using-alb-ingress-controller

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
        "PolicyId": "ANPA6GSNG3KEPISL5QO7G",
        "Arn": "arn:aws:iam::976193247880:policy/AWSLoadBalancerControllerIAMPolicy",
        "Path": "/",
        "DefaultVersionId": "v1",
        "AttachmentCount": 0,
        "PermissionsBoundaryUsageCount": 0,
        "IsAttachable": true,
        "CreateDate": "2025-01-02T13:11:29+00:00",
        "UpdateDate": "2025-01-02T13:11:29+00:00"
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
  --attach-policy-arn=arn:aws:iam::976193247880:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve
```

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
  --set clusterName=eks-demo \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
  
  
helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller \
    --set clusterName=eks-demo \
    --set serviceAccount.create=false \
    --set region=us-east-1 \
    --set vpcId=vpc-069c83cc0370c9b2a \
    --set serviceAccount.name=aws-load-balancer-controller \
    -n kube-system  
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

Verify controller is installed:

```
kubectl get deployment -n kube-system aws-load-balancer-controller
```

Expected output:

```
NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
aws-load-balancer-controller   2/2     2            2           5m20s
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

Expected output:

NAME: aws-load-balancer-controller
LAST DEPLOYED: Wed Jan  1 20:53:05 2025
NAMESPACE: kube-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
AWS Load Balancer controller installed!

To uninstall:

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
kubectl expose deployment web2 --type=NodePort --port=8080 
```

Expected output:

```
service/web exposed
service/web2 exposed
```

Apply Ingress rules

```
kubectl apply -f ingress-rules.yaml
```

The load balancer should launch and you will be able to access the applications via:
http://load-balancer-url/v1
http://load-balancer-url/v2
