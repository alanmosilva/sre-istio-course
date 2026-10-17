# 12 — Revisão geral e Cleanup

## Objetivo

Fechar o curso com um mapa mental de tudo que foi visto e desmontar o LAB sem deixar recursos AWS órfãos.

---

# Parte 1 — Resumão

## Service Mesh

Istio acrescenta ao tráfego entre workloads:

```text
mTLS
identity
authorization
traffic management
telemetry
ingress
egress
```

## Sidecar Mode

```text
Pod
├── App
└── Envoy
```

Principais recursos:

```text
VirtualService
DestinationRule
PeerAuthentication
AuthorizationPolicy
```

Envoy:

```text
Listener
→ Route
→ Cluster
→ Endpoint
```

## Segurança

```text
PeerAuthentication
→ autenticação/mTLS

AuthorizationPolicy
→ autorização
```

Identidade:

```text
SPIFFE
+
ServiceAccount
```

## Ingress

```text
Internet
↓
AWS NLB
↓
Ingress Gateway
↓
Gateway / Gateway API
↓
Route
↓
Service
↓
Pod
```

## TLS

```text
HTTPS externo
≠
mTLS interno do mesh
```

## Egress

```text
ServiceEntry
→ registra destino externo

Egress Gateway
→ caminho centralizado de saída
```

## Ambient

```text
ztunnel
→ L4, identity, mTLS

Waypoint
→ L7
```

Regra:

```text
L4 AuthorizationPolicy
selector
→ ztunnel

L7 AuthorizationPolicy
targetRefs
→ Waypoint
```

Traffic Management recomendado neste curso:

```text
HTTPRoute
+
Services separados por versão
```

## Troubleshooting

```text
DNS
↓
Service
↓
EndpointSlice
↓
Route
↓
Cluster
↓
Endpoint
↓
mTLS
↓
Authorization
↓
Gateway/Waypoint
↓
Logs/Métricas
```

---

# Parte 2 — Cleanup

## ATENÇÃO

Antes de destruir o EKS com Terraform, remova LoadBalancers provisionados pelos recursos Kubernetes/Istio.

Caso contrário, dependências na AWS podem impedir ou complicar o `terraform destroy`.

---

## 1. Liste LoadBalancer Services

```bash
kubectl get svc -A \
  --field-selector spec.type=LoadBalancer
```

Anote os owners.

---

## 2. Remova Gateways da Gateway API

Liste:

```bash
kubectl get gateways.gateway.networking.k8s.io -A
```

Exemplo:

```bash
kubectl delete gateways.gateway.networking.k8s.io \
  backend-gateway-api \
  -n gateway-api-lab
```

Não exclua apenas o Service.

O Gateway controller pode recriar o Service enquanto o `Gateway` continuar existindo.

Valide:

```bash
kubectl get svc -A \
  --field-selector spec.type=LoadBalancer
```

---

## 3. Remova Waypoints

Waypoints também são recursos Gateway API.

Liste:

```bash
kubectl get gateways.gateway.networking.k8s.io -A
```

Remova os que forem Waypoint e não forem mais necessários:

```bash
kubectl delete gateways.gateway.networking.k8s.io \
  waypoint \
  -n ambient-lab \
  --ignore-not-found
```

Repita para namespaces adicionais onde criou Waypoint.

---

## 4. Remova ingress gateway separado

Como o curso instalou usando `ingress.yaml`:

```bash
istioctl uninstall \
  -f ../05-ingress-gateway-tls/ingress.yaml \
  -y
```

Se preferir seguir a limpeza específica documentada para o namespace do gateway:

```bash
istioctl uninstall \
  --istioNamespace istio-ingress \
  -y \
  --purge
```

Depois:

```bash
kubectl delete namespace istio-ingress \
  --ignore-not-found
```

> `--purge` remove recursos compartilhados quando usado para desinstalação completa. Em ambientes reais com múltiplos control planes/revisions, valide cuidadosamente o escopo antes de executá-lo.

---

## 5. Remova egress gateway

Como foi instalado pelo arquivo do curso:

```bash
istioctl uninstall \
  -f ../07-egress/egress.yaml \
  -y
```

Depois:

```bash
kubectl delete namespace istio-egress \
  --ignore-not-found
```

---

## 6. Remova namespaces do LAB

```bash
kubectl delete namespace \
  istio-lab \
  ambient-lab \
  legacy \
  gateway-api-lab \
  --ignore-not-found
```

---

## 7. Remova addons

No diretório da distribuição do Istio:

```bash
kubectl delete -f samples/addons \
  --ignore-not-found
```

Se preferir, remova individualmente os addons usados.

---

## 8. Desinstale Istio

Quando não houver mais workloads/gateways dependentes:

```bash
istioctl uninstall \
  --purge \
  -y
```

Depois:

```bash
kubectl delete namespace istio-system \
  --ignore-not-found
```

---

## 9. Gateway API CRDs

Se você deseja remover também os CRDs utilizados no LAB:

```bash
kubectl kustomize \
  "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v1.6.0" \
  | kubectl delete -f -
```

Não faça isso em cluster compartilhado antes de verificar quem mais utiliza Gateway API.

---

## 10. Validação final Kubernetes

```bash
kubectl get svc -A \
  --field-selector spec.type=LoadBalancer

kubectl get gateways.gateway.networking.k8s.io -A

kubectl get ns
```

Não deve restar LoadBalancer do curso.

---

## 11. Validação AWS

```bash
aws elbv2 describe-load-balancers \
  --query "LoadBalancers[].{Name:LoadBalancerName,DNS:DNSName,Scheme:Scheme}" \
  --output table
```

Confirme que nenhum NLB do LAB permanece.

---

## 12. Terraform destroy

Somente agora volte ao repositório:

```text
sre-aws-eks
```

Revise:

```bash
terraform plan -destroy
```

Depois:

```bash
terraform destroy
```

---

# Checklist final

```text
[ ] Gateway API removido
[ ] Waypoints removidos
[ ] ingress gateway removido
[ ] egress gateway removido
[ ] namespaces do curso removidos
[ ] addons removidos
[ ] Istio removido
[ ] nenhum Service LoadBalancer restante
[ ] nenhum NLB do LAB restante
[ ] terraform destroy executado
```

Curso concluído.
