# Aqua Security for GCP Marketplace

This github repo holds the helm charts and kubernets applications manifest for Aqua Security's GCP Kubernetes Application Market segment offering. This readme includes reference documention regarding installation and upgrades while operating within Google Kubernetes Engine. 

Installation is simple, as Cloud Native apps should be. There is a minimal pre-requsite to attend to - Aqua recommends running the Container Security Platform in a dedicated namespace. At the time of this writing creating a namespace via kubectl is required. Fortunatly, it's also very easy using the cloud shell. First, authenticate to the cluster, then create a namespace as follows:
```
kubectl create namespace aqua-security
```
Then, navigate to the [Aqua Security GCP marketplace offer.](https://www.google.com/url?q=https://console.cloud.google.com/marketplace/details/aquasecurity-public/aqua-container-security)
Click configure, selecting the cluster and namespace which you just created.
Now be patient as the deployment takes approximately three minutes.

The marketplace deployer will automatically deploy the Aqua Command Center and accompanying Aqua Enforcers set to audit mode. This process takes approx. three minutes. The following four basic steps are necessary to complete deployment:
    
### 1. Backup Auto-Generated Secrets
By default the Aqua postgresql container utilizes a persistant volume (PVC). When removing the application, this PVC is not deleted along with your application in order to save your data.
In the case you re-deploy using the same application name and namespace, reloading these secrets will be necessary to access the db files on the reused PVC.
Please back them up now and see the getting started guide for more detail.
```shell
kubectl get secrets -l secretType=aquaSecurity \
--namespace {{ .Release.Namespace }} -o json > aquaSecrets.json
```

### 2. Obtain the Aqua Command Center portal information:
A user may run the following command or click on the Services tab and look for {{ .Release.Name }}-server-svc.
```shell
SERVICE_IP=$(kubectl get svc {{ .Release.Name }}-server-svc \
--namespace {{ .Release.Namespace }} \
--output jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "http://${SERVICE_IP}:8080"
```

### 3. Obtain the Aqua Command Center administrator password
The default username is `administrator`. Use `kubectl` to extract the generated password from the secret.
```shell
kubectl get secret {{ .Release.Name }}-admin-pass \
--namespace {{ .Release.Namespace }} \
--output=jsonpath='{.data.password}' | base64 --decode
```

### 4. Enter the license to enable the product
Users that have a license token for GKE Marketplace should enter it to enable the PAYG billing of Enforcers. If you do not have a license token, you may request one by filling out the form [here.](https://www.aquasec.com/aqua-signup/?type=marketplace-gke)

### View logs of the Aqua Command Center
Sometimes a person just needs the read some logs. While these are accessible in the Aqua console under Settings > Logs, should you need to access logs of the Aqua server pod, use the below command.
```shell
SERVERPOD=$(kubectl get pods -l app=appName-server \
--namespace nameSpace --no-headers -o=custom-columns=NAME:.metadata.name)
kubectl logs -f ${SERVERPOD} --namespace=nameSpace
```
