helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

helm show values argo/argo-cd --version 9.2.2 > values-default.yaml

helm template argocd argo/argo-cd \
  --version 9.2.2 \
  -f values-custom.yaml \
  > install.yaml
