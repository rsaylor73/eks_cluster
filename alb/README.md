# Video Intro

https://www.youtube.com/watch?v=8AiIBNnDVkg

Credits: https://www.youtube.com/@ExecuteonCommand (Thank you for providing Load Balancer instruction)

# Create Load Balancer

https://kubernetes.github.io/ingress-nginx/deploy/#aws

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.0-beta.0/deploy/static/provider/aws/deploy.yaml

# View Resources

kubectl get all -n ingress-nginx

# Sample yaml files

https://github.com/jmbharathram/executeoncommand/tree/master/ingress

# Deploy

Check the IP values in frontend1-service.yaml before deploying.

```
kubectl apply -f frontend1-deployment.yaml 
kubectl apply -f frontend1-service.yaml
kubectl apply -f frontend2-deployment.yaml
kubectl apply -f frontend2-service.yaml
kubectl apply -f ingressclass.yaml
kubectl apply -f ingress.yaml
```

You might have to wait a few minutes for the load balancer to register with the ingress.

```
kubectl get ingress
```

Once the Address field has the load balancer DNS value you should be ready to start using the load balancer.

# Load Balancer

The URL should be loadbalancer-dns-name/nginx and loadbalancer-dns-name/httpd

Note: If you discover that one works vs the other does not please make sure you
have enabled a NAT gateway for every private subnet in the VPC module.



