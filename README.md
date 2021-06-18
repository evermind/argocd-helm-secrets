# argocd-helm-secrets
Docker and helm-charts for ArgoCD with helm-secrets support

inspired by 
* <https://faun.pub/handling-kubernetes-secrets-with-argocd-and-sops-650df91de173>
* <https://github.com/ventx/argocd-helm-secrets/blob/master/Dockerfile>

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
