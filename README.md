# argocd-helm-secrets
Docker and helm-charts for ArgoCD with helm-secrets support

inspired by 
* <https://faun.pub/handling-kubernetes-secrets-with-argocd-and-sops-650df91de173>
* <https://github.com/ventx/argocd-helm-secrets/blob/master/Dockerfile>

Version is equal to used arcocd base image.

## Features
* based on official docker from https://github.com/argoproj/argo-cd/
* support SOPS encrypted files in helm charts

## Using
* export gpg key `gpg --export-secret-keys YOUR_ID_HERE > private.key`
* mount private key inside container to /home/argocd/gpg/gpg.asc

## Components
* argocd
* helm secrets plugin https://github.com/jkroepke/helm-secrets
* gpg
* sops

## Hints / lesson learned

1) Argocd creates seperate helm environment per call or deployment. So plugins installed by Dockerfile arn´t used. Set $HELM_PLUGINS in Dockerfile prevents this problem.
2) Argocd uses the same image for various roles (server, repoServer ...). Helm secrets is needed in repoServer. So there also mounted gpg secrets required.

## Example deployment 

values.yaml
```
global:
  # abweichendes repo für integration des helm secrets plugin
  image:
    repository: evermind/argocd-helm-secrets
    tag: "latest"
    imagePullPolicy: Always

[...]

repoServer:
  extraArgs:
  - --repo-cache-expiration 12h
  
  ## Additional volumeMounts for gpg key import
  volumeMounts: 
  - name: gpg-secret
    mountPath: /home/argocd/gpg
  volumes: 
  - name: gpg-secret
    secret:
      secretName: gpg-key  

```

