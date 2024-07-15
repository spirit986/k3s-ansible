### Test MetalLB and Ingress deployment and the IP address allocation
**IMPORTANT NOTE:** 
Make sure that you create the namespace first with the example provided in: `example/advanced/nginx-test-deployments-namespace.yml`
Create the namespace:
```bash
$ kubectl apply -f example/advanced/nginx-test-deployments-namespace.yml
```

Use the scripts provided to generate an example deployment files.
1. Deployment files generated from `generate_deployment_file_metallb.sh` will test metallb only. Successfull deployment will provision an NGINX deployment with a Loadbalancer service with an IP address from your metallb pool.
2. If you have also used the helm addons option while deploying the cluster then you can use the `generate_deployment_file_ingress.sh` script to generate deployment files that will test both the metallb and ingress-nginx modules.
3. To use the ingress option properly you need to have valid dns names registered for your ingress services or update your local hosts file with your desired host names.

The bellow example will create a full deployment, service with metallb and ingress with ingress-nginx for a service named `smoketestestservice mytestdomain.org`
```bash
$ ./generate_deployment_file_ingress.sh smoketestservice1 tomspirit.me 172.16.1.51
Deployment file: smoketestservice1-ingress-deployment.yml was generated.

$ kubectl apply -f smoketestservice1-ingress-deployment.yml
deployment.apps/smoketestservice1-deployment created
service/smoketestservice1-service created
ingress.networking.k8s.io/smoketestservice1-ingress created
```

### Verify
Check general service statistics. MetalLB should successfully apply the "EXTERNAL-IP" from the IP pool.
```bash
$ kubectl get services -n smoketest-deployments
NAME                        TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
smoketestservice1-service   LoadBalancer   10.43.190.101   172.16.1.51   80:32080/TCP   8s
```

Get ingress-information:
```bash
$ kubectl describe ingress smoketestservice1-ingress -n smoketest-deployments
Name:             smoketestservice1-ingress
Labels:           app=smoketestservice1
Namespace:        smoketest-deployments
Address:          172.16.1.50
Ingress Class:    nginx
Default backend:  <default>
Rules:
  Host                            Path  Backends
  ----                            ----  --------
  smoketestservice1.tomspirit.me
                                  /   smoketestservice1-service:80 (10.42.3.19:80,10.42.4.19:80,10.42.5.19:80)
Annotations:                      <none>
Events:
  Type    Reason  Age                 From                      Message
  ----    ------  ----                ----                      -------
  Normal  Sync    95s (x2 over 116s)  nginx-ingress-controller  Scheduled for sync
```

From the browser or with `curl` confirm that you can reach the IPs.
Also for the 2nd command to work you need to have a proper DNS resolution set up and working, or set the domain name in your hosts file with the IP address in question. 
```bash
$ curl http://172.16.1.51
smoketestservice1 | ingress-nginx works properly with MetalLB

$ curl http://smoketestservice1.tomspirit.me
smoketestservice1 | ingress-nginx works properly with MetalLB
```
