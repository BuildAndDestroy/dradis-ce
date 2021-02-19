# dradis-container Docker


## Build from docker file

```
docker build -t DockerRegisteryDomainHere/Username/dradis-ce:latest .
```

## Pull from your Private Registry
```
docker pull DockerRegisteryDomainHere/Username/dradis:latest
```

## Run the container and access gui:
```
docker run -it -p 3000:3000 DockerRegisteryDomainHere/Username/dradis:latest
```
* http://127.0.0.1:3000/

## Restart the container if it fails:
```
docker start <container ID>
```

## Notes
* Be aware the the data is persistent when using the container, but new containers are clean.

# dradis-container Kubernetes

## Generate your key and crt
```
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls-dradis-ce.key -out tls-dradis-ce.crt -subj "/CN=dradis-ce-laptop.yourdomain.com"
```

## Convert to base64 and add to dradis-deploy.yaml
```
cat tls-dradis-ce.crt | base64
cat tls-dradis-ce.key | base64

vi dradis-deploy.yaml
..
..
  tls.crt: # add base64 here
  tls.key: # add base64 here
```

## Add your docker registry creds to dradis-deploy.yaml
```
cat ~/.docker/config.json | base64

vi dradis-deploy.yaml
..
..
  .dockerconfigjson: {{ cat ~/.docker/config.json | base64 }}
```

## Deploy Dradis:
```
kubectl apply -f dradis-deploy.yaml
```

# Kubernetes Deployment
* We use dradis-k8s.docker file to build a pod. The db will be removed since we rely on persistent storage.
* Once the pods is deployed/redeployed, we access the container and link the storage mount db to our dradis deployment.
** Once the inital setup is done, this process is no longer needed to upgrade images as the db directory is persistent.
```
docker exec -it -u root <container id> /bin/bash
ln -s /mnt/dradis-ce/db /home/dradis/dradis-ce/
```
* The previous Redis db will be linked to the Dradis frontend, retaining all previous engagment activity.
