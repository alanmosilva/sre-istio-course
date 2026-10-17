#!/usr/bin/env bash
set -euo pipefail

echo "== Kubernetes LoadBalancer Services =="
kubectl get svc -A --field-selector spec.type=LoadBalancer || true

echo
echo "== Gateway API resources =="
kubectl get gateways.gateway.networking.k8s.io -A || true

echo
echo "== HTTPRoutes =="
kubectl get httproute -A || true

echo
echo "== AWS Load Balancers =="
aws elbv2 describe-load-balancers \
  --query "LoadBalancers[].{Name:LoadBalancerName,DNS:DNSName,Scheme:Scheme}" \
  --output table || true

echo
echo "Revise os recursos acima antes de executar terraform destroy."
