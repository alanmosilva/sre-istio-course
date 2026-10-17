# 05 — Ingress Gateway, AWS NLB, TLS e Gateway API

## Objetivo

Expor aplicações do mesh externamente com um ponto de entrada controlado.

## Parte A — Istio Gateway clássico

### 1. Instalar ingress gateway separado

O arquivo `ingress.yaml` é configuração de instalação do `istioctl`.

Use:

```bash
istioctl install -f ingress.yaml -y
```

**Não use `kubectl apply -f ingress.yaml` neste fluxo.**

Valide:

```bash
kubectl get pods,svc -n istio-ingress
```

O Service deve criar um NLB `internet-facing`.

### 2. Gateway + VirtualService

```bash
kubectl apply -f gateway.yaml
kubectl apply -f virtual-service.yaml
```

### 3. AuthorizationPolicy

Se o backend já possui ALLOW policy, o ingress gateway também precisa ser autorizado.

Identidade esperada:

```text
cluster.local/ns/istio-ingress/sa/istio-ingressgateway-service-account
```

## Parte B — TLS

### 1. LAB com certificado self-signed

```bash
openssl req \
  -x509 \
  -nodes \
  -days 365 \
  -newkey rsa:2048 \
  -keyout tls.key \
  -out tls.crt \
  -subj "/CN=api.istio.lab" \
  -addext "subjectAltName=DNS:api.istio.lab"
```

Secret:

```bash
kubectl create secret tls backend-tls \
  -n istio-ingress \
  --cert=tls.crt \
  --key=tls.key
```

Aplique:

```bash
kubectl apply -f gateway-https.yaml
```

### 2. /etc/hosts no LAB

Obtenha o DNS:

```bash
kubectl get svc -n istio-ingress
```

Resolva o NLB:

```bash
dig +short <DNS_DO_NLB>
```

Escolha um IP retornado:

```text
44.x.x.x api.istio.lab
```

em `/etc/hosts`.

> `/etc/hosts` recebe IP, não hostname.

Teste:

```bash
curl -vk https://api.istio.lab/api/v1
```

Melhor:

```bash
curl --cacert tls.crt \
  https://api.istio.lab/api/v1
```

TLS externo e mTLS interno são camadas diferentes.

---

## Parte C — Gateway API

### 1. Instalar CRDs

```bash
kubectl kustomize \
  "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v1.6.0" \
  | kubectl apply -f -
```

### 2. Criar namespace

```bash
kubectl create namespace gateway-api-lab
```

### 3. Gateway + HTTPRoute

```bash
kubectl apply -f gateway-api.yaml
kubectl apply -f http-route.yaml
```

Valide:

```bash
kubectl get gateways.gateway.networking.k8s.io -A
kubectl get httproute -A
```

Procure:

```text
PROGRAMMED=True
Accepted=True
ResolvedRefs=True
```

## Atenção ao cleanup

Gateway API pode provisionar Service e LoadBalancer automaticamente.

Se você apagar somente o Service:

```bash
kubectl delete svc <service>
```

o controller pode recriá-lo.

Remova o owner:

```bash
kubectl delete gateways.gateway.networking.k8s.io \
  backend-gateway-api \
  -n gateway-api-lab
```

## Retomando o LAB após recriar o EKS

Se aparecer:

```text
no matches for kind "Gateway"
```

reinstale os Gateway API CRDs.

Se `kubectl apply -f ingress.yaml` falhar:

```text
no matches for kind "IstioOperator"
```

lembre que este arquivo é consumido por:

```bash
istioctl install -f ingress.yaml -y
```

## Checkpoint

Você deve conseguir explicar:

```text
Internet
↓
AWS NLB
↓
Istio Ingress Gateway
↓
Gateway / HTTPRoute
↓
Service
↓
Workload
```
