#!/usr/bin/env bash
set -euo pipefail

echo "== AWS identity =="
aws sts get-caller-identity

echo
echo "== Kubernetes nodes =="
kubectl get nodes -o wide

echo
echo "== LoadBalancer services =="
kubectl get svc -A --field-selector spec.type=LoadBalancer || true

echo
echo "== Istio version =="
istioctl version || true

echo
echo "== Gateway API =="
kubectl get gatewayclass || true
