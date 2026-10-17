# 08 — Ambient Mesh, ztunnel e Waypoint

## Objetivo

Operar Istio sem sidecar por Pod.

## 1. Habilitar Ambient

No cluster do LAB já com Istio instalado:

```bash
istioctl upgrade --set profile=ambient
```

Valide:

```bash
kubectl get daemonset -n istio-system
kubectl get pods -n istio-system
```

Procure:

```text
istio-cni
ztunnel
```

## 2. Namespace Ambient

```bash
kubectl create namespace ambient-lab

kubectl label namespace ambient-lab \
  istio.io/dataplane-mode=ambient
```

Aplicar:

```bash
kubectl apply -f app.yaml
```

Valide:

```bash
kubectl get pods -n ambient-lab
```

Esperado:

```text
1/1
```

Não há Envoy sidecar no Pod.

## 3. ztunnel

```bash
istioctl ztunnel-config workloads
```

Certificados:

```bash
kubectl get pods \
  -n istio-system \
  -l app=ztunnel \
  -o wide
```

Depois:

```bash
istioctl ztunnel-config certificates \
  <ZTUNNEL_POD> \
  -n istio-system
```

Ou use `--node`.

## 4. Waypoint

ztunnel trabalha principalmente em L4.

Para recursos L7:

```bash
istioctl waypoint apply \
  -n ambient-lab \
  --enroll-namespace
```

Valide:

```bash
kubectl get gateways.gateway.networking.k8s.io \
  -n ambient-lab
```

Namespace:

```bash
kubectl get ns ambient-lab --show-labels
```

Espere:

```text
istio.io/dataplane-mode=ambient
istio.io/use-waypoint=waypoint
```

## 5. AuthorizationPolicy L7

No Ambient:

```text
L4
selector
→ ztunnel

L7
targetRefs
→ Waypoint
```

Aplique:

```bash
kubectl apply -f authorization-policy-l7.yaml
```

### Muito importante

Não aplique uma policy com:

```yaml
selector:
...
methods:
paths:
```

esperando que o ztunnel interprete HTTP.

ztunnel não aplica atributos L7.

O comportamento é fail-safe e a policy pode ficar mais restritiva que o esperado.

## 6. Traffic Management

Para Ambient + Waypoint, prefira Gateway API.

Este curso usa:

```text
HTTPRoute
+
Service backend-v1
+
Service backend-v2
```

Aplicar:

```bash
kubectl apply -f services-versions.yaml
kubectl apply -f http-route-weighted.yaml
```

Não misture `VirtualService` e `HTTPRoute` para o mesmo workload.

## 7. Header routing

```bash
kubectl apply -f http-route-header.yaml
```

Teste:

```bash
kubectl exec -n ambient-lab client -- \
  curl -s \
  -H 'x-version: v2' \
  http://backend/api/v1
```

## 8. Timeout

Exemplo Gateway API:

```yaml
timeouts:
  request: 2s
```

Retry explícito pode depender da versão/feature set disponível. O curso evita ensinar uma extensão instável como regra geral.

## PRODUÇÃO

Ambient reduz sidecars por Pod, mas continua exigindo operação:

```text
istiod
istio-cni
ztunnel
waypoints
Gateway API
policies
```

## Checkpoint

```text
ztunnel
→ L4, identidade, mTLS, L4 auth

Waypoint
→ L7 routing, HTTP authorization, telemetry L7
```
