# 02 — Sidecar Mode e Envoy

## Objetivo

Instalar o Istio em Sidecar Mode e entender o caminho do tráfego dentro do Envoy.

## 1. Instalação

A partir do diretório baixado do Istio:

```bash
istioctl install \
  -f samples/bookinfo/demo-profile-no-gateways.yaml \
  -y
```

Valide:

```bash
kubectl get pods -n istio-system
istioctl version
```

## 2. Namespace do LAB

```bash
kubectl create namespace istio-lab

kubectl label namespace istio-lab \
  istio-injection=enabled
```

Aplicar:

```bash
kubectl apply -f app.yaml
```

Valide:

```bash
kubectl get pods -n istio-lab
```

Esperado:

```text
READY
2/2
```

Um container é a aplicação, o outro é `istio-proxy`.

## 3. Caminho no Envoy

Modelo mental:

```text
Listener
  ↓
Route
  ↓
Cluster
  ↓
Endpoint
```

### Listener

Onde o Envoy recebe tráfego.

```bash
istioctl proxy-config listeners \
  deploy/backend-v1 -n istio-lab
```

### Routes

```bash
istioctl proxy-config routes \
  deploy/backend-v1 -n istio-lab
```

### Clusters

```bash
istioctl proxy-config clusters \
  deploy/backend-v1 -n istio-lab
```

### Endpoints

```bash
istioctl proxy-config endpoints \
  deploy/backend-v1 -n istio-lab
```

## 4. Sincronização

```bash
istioctl proxy-status
```

Use este comando para identificar proxies fora de sincronia com `istiod`.

## 5. EDS na prática

Escale o backend:

```bash
kubectl scale deployment backend-v1 \
  -n istio-lab \
  --replicas=3
```

Veja o Kubernetes:

```bash
kubectl get endpointslices -n istio-lab
```

Depois veja o Envoy:

```bash
istioctl proxy-config endpoints \
  deploy/client \
  -n istio-lab
```

O objetivo é enxergar que o proxy recebe os endpoints descobertos pelo control plane.

## PRODUÇÃO

Não use apenas `kubectl get pods`.

Quando a aplicação está Running mas o tráfego falha, investigue:

```text
Kubernetes
+
configuração que chegou ao proxy
```

## Troubleshooting

```bash
istioctl analyze

istioctl proxy-status

kubectl logs \
  -n istio-lab \
  deploy/backend-v1 \
  -c istio-proxy
```

## Checkpoint

Você deve entender:

```text
istiod
→ configura
→ Envoy

Envoy
Listener → Route → Cluster → Endpoint
```
