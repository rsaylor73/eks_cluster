# Tutorial

https://www.youtube.com/watch?v=ZGKaSboqKzk&t=189s

https://github.com/listentolearn/aws-eks-app-deployment/blob/main/loadbalancer-trust-policy.json

Install the service after creating the load balancer policy and role

> kubectl create -f hello-world/service.yaml

Install helm then run the following:

> helm repo add eks https://aws.github.io/eks-charts

Helm install load balancer

helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system \
--set clusterName=eks-demo \
--set serviceAccount.create=false \
--set serviceAccount.name=aws-load-balancer-controller
