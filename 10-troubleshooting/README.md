# 10 — Troubleshooting prático

## Objetivo

Resolver os problemas mais comuns sem transformar o curso em uma enciclopédia.

Formato:

```text
Sintoma
→ investigação
→ evidência
→ causa
→ correção
```

---

## 10.1 — curl exit code 6

Sintoma:

```text
curl: (6) Could not resolve host
```

Investigue:

```bash
kubectl get svc -n <namespace>

kubectl exec -n <namespace> <client> -- \
  nslookup <service>

kubectl exec -n <namespace> <client> -- \
  cat /etc/resolv.conf
```

Causa comum:

```text
Service não existe
```

Correção:

criar/restaurar o Service.

---

## 10.2 — 503 UH

Sintoma:

```text
503 UH
```

`UH`:

```text
No Healthy Upstream
```

Investigue:

```bash
kubectl get pods,svc,endpointslices -n <namespace>

istioctl proxy-config endpoints \
  <pod> \
  -n <namespace>
```

Causas comuns:

- selector errado;
- Pod não Ready;
- Service sem endpoint;
- porta errada;
- subset sem workload.

---

## 10.3 — NR

Sintoma em access log:

```text
NR
```

Significa:

```text
No Route
```

Sidecar:

```bash
istioctl proxy-config routes \
  <pod> \
  -n <namespace>
```

Gateway API:

```bash
kubectl get httproute -A
kubectl describe httproute <route> -n <namespace>
```

Procure:

```text
Accepted=True
ResolvedRefs=True
```

Causas:

- host errado;
- path errado;
- Gateway errado;
- parentRef incorreto;
- backendRef inválido.

---

## 10.4 — RBAC: access denied

Sintoma:

```text
RBAC: access denied
```

Investigue:

```bash
kubectl get authorizationpolicy -A

kubectl get authorizationpolicy \
  -n <namespace> \
  -o yaml
```

Ambient:

```text
L4 selector → ztunnel
L7 targetRefs → Waypoint
```

Causas comuns:

- principal incorreto;
- ServiceAccount incorreto;
- ingress não autorizado;
- policy L7 aplicada ao ztunnel;
- tráfego não passando pelo Waypoint.

---

## 10.5 — mTLS

Veja:

```bash
kubectl get peerauthentication -A
```

Sidecar:

```bash
istioctl proxy-status
```

Ambient:

```bash
istioctl ztunnel-config workloads
```

Causa típica:

```text
server exige STRICT
+
cliente não está corretamente no mesh
```

---

## 10.6 — Waypoint retorna 503

```bash
kubectl get gateways.gateway.networking.k8s.io -A
kubectl get httproute -A
istioctl ztunnel-config workloads
kubectl get authorizationpolicy -A
```

Causas:

- Waypoint não `PROGRAMMED`;
- namespace sem `istio.io/use-waypoint`;
- HTTPRoute aponta para Service inexistente;
- backendRef sem endpoint;
- policy antiga bloqueando o Waypoint.

---

## Fluxo de troubleshooting

```text
DNS resolve?
↓
Service existe?
↓
Há endpoints?
↓
dataplane conhece workload?
↓
Há route?
↓
Há cluster/endpoints?
↓
Gateway/Waypoint está saudável?
↓
mTLS está compatível?
↓
AuthorizationPolicy permite?
↓
logs/métricas
```

## Comandos essenciais

```bash
kubectl get pods,svc,endpointslices -n <namespace>

istioctl analyze
istioctl proxy-status

istioctl proxy-config routes <pod>
istioctl proxy-config clusters <pod>
istioctl proxy-config endpoints <pod>

istioctl ztunnel-config workloads

kubectl get authorizationpolicy,peerauthentication -A

kubectl logs <pod> -c istio-proxy
```

## Regra SRE

Não altere configuração antes de coletar evidência suficiente para saber **qual camada está falhando**.
