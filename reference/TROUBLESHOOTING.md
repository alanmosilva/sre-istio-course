# Troubleshooting Reference

## DNS

```bash
kubectl exec -n <ns> <client> -- nslookup <service>
```

curl code 6:

```text
Could not resolve host
```

## Service

```bash
kubectl get svc <service> -n <ns> -o yaml
```

## Endpoints

```bash
kubectl get endpointslices \
  -n <ns> \
  -l kubernetes.io/service-name=<service>
```

## Proxy sync

```bash
istioctl proxy-status
```

## Routes

```bash
istioctl proxy-config routes <pod> -n <ns>
```

## Clusters

```bash
istioctl proxy-config clusters <pod> -n <ns>
```

## Endpoints vistos pelo Envoy

```bash
istioctl proxy-config endpoints <pod> -n <ns>
```

## Ambient

```bash
istioctl ztunnel-config workloads
```

## Waypoint

```bash
kubectl get gateways.gateway.networking.k8s.io -A
```

Procure:

```text
PROGRAMMED=True
```

## HTTPRoute

```bash
kubectl describe httproute <nome> -n <ns>
```

Procure:

```text
Accepted=True
ResolvedRefs=True
```

## Authorization

```bash
kubectl get authorizationpolicy -A
kubectl get authorizationpolicy -n <ns> -o yaml
```

## PeerAuthentication

```bash
kubectl get peerauthentication -A
```

## Response flags

| Flag | Significado |
|---|---|
| `-` | nenhuma flag especial |
| `UH` | no healthy upstream |
| `UF` | upstream connection failure |
| `NR` | no route |
| `UO` | upstream overflow |

## Fluxo

```text
1. DNS
2. Service
3. EndpointSlice
4. dataplane
5. route
6. cluster
7. endpoint
8. Gateway/Waypoint
9. mTLS
10. AuthorizationPolicy
11. logs/métricas
```
