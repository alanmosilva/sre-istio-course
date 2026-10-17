# Comandos rápidos

## Cluster

```bash
kubectl get nodes
kubectl get pods -A
kubectl get svc -A
```

## Istio

```bash
istioctl version
istioctl analyze
istioctl proxy-status
```

## Envoy

```bash
istioctl proxy-config listeners <pod> -n <ns>
istioctl proxy-config routes <pod> -n <ns>
istioctl proxy-config clusters <pod> -n <ns>
istioctl proxy-config endpoints <pod> -n <ns>
```

## Logs

```bash
kubectl logs <pod> -n <ns> -c istio-proxy
```

## Segurança

```bash
kubectl get peerauthentication -A
kubectl get authorizationpolicy -A
```

## Ambient

```bash
istioctl ztunnel-config workloads

kubectl get ds -n istio-system

kubectl get gateways.gateway.networking.k8s.io -A
```

## Waypoint

```bash
istioctl waypoint apply -n <ns> --enroll-namespace

kubectl get gateways.gateway.networking.k8s.io \
  -n <ns>
```

## Gateway API

```bash
kubectl get gatewayclass
kubectl get gateways.gateway.networking.k8s.io -A
kubectl get httproute -A
kubectl describe httproute <nome> -n <ns>
```

## Service / Endpoint

```bash
kubectl get svc -n <ns>
kubectl get endpointslices -n <ns>
```

## LoadBalancers

```bash
kubectl get svc -A \
  --field-selector spec.type=LoadBalancer
```

## AWS NLB

```bash
aws elbv2 describe-load-balancers \
  --query "LoadBalancers[].{Name:LoadBalancerName,DNS:DNSName,Scheme:Scheme}" \
  --output table
```
