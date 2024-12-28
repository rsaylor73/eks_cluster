# Video Intro

https://www.youtube.com/watch?v=8AiIBNnDVkg

# Create Load Balancer

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.0-beta.0/deploy/static/provider/aws/deploy.yaml

# View Resources

kubectl get all -n ingress-nginx

# Sample yaml files

https://github.com/jmbharathram/executeoncommand/tree/master/ingress

# Deploy

Check the IP values in frontend1-service.yaml before deploying.

kubectl create -f frontend1-deployment.yaml 
kubectl create -f frontend1-service.yaml
kubectl create -f frontend2-deployment.yaml
kubectl create -f frontend2-service.yaml
kubectl create -f ingressclass.yaml
kubectl create -f ingress.yaml
 

# Load Balancer

The URL should be loadbalancer-dns-name/nginx1 and loadbalancer-dns-name/nginx2



