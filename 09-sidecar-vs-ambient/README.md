# 09 — Sidecar vs Ambient e migração

## Objetivo

Comparar os modelos e praticar uma migração reversível.

## 1. Comparação

| Tema | Sidecar | Ambient |
|---|---|---|
| dataplane | Envoy por Pod | ztunnel por node |
| L7 | no sidecar | Waypoint |
| Pod | 2/2 | 1/1 |
| upgrade proxy | reinjeção/restart | componente desacoplado |
| traffic API preferida neste curso | VirtualService/DR | HTTPRoute |
| L7 AuthorizationPolicy | selector | targetRefs |

## 2. Backup antes da migração

```bash
kubectl get \
  virtualservice,destinationrule,authorizationpolicy,peerauthentication \
  -n istio-lab \
  -o yaml \
  > istio-config-backup.yaml
```

## 3. Waypoint

```bash
istioctl waypoint apply \
  -n istio-lab
```

Valide:

```bash
kubectl get gateways.gateway.networking.k8s.io \
  waypoint \
  -n istio-lab
```

## 4. Migrar regras L7

Antes de remover sidecars:

- migre `VirtualService` para `HTTPRoute` quando aplicável;
- crie Services separados por versão para weighted routing;
- migre L7 `AuthorizationPolicy` de `selector` para `targetRefs`.

**Não misture VirtualService e HTTPRoute para o mesmo workload.**

## 5. Enroll Ambient

```bash
kubectl label namespace istio-lab \
  istio.io/dataplane-mode=ambient

kubectl label namespace istio-lab \
  istio.io/use-waypoint=waypoint
```

Valide:

```bash
istioctl ztunnel-config workloads | grep istio-lab
```

## 6. Remover sidecar injection

```bash
kubectl label namespace istio-lab \
  istio-injection-
```

Restart:

```bash
kubectl rollout restart deployment -n istio-lab
```

Para Pod standalone:

```bash
kubectl delete pod client -n istio-lab
kubectl apply -f ../02-sidecar-envoy/app.yaml
```

Valide:

```bash
kubectl get pods -n istio-lab
```

Esperado:

```text
1/1
```

## 7. Incidente real importante

Uma L7 policy antiga como:

```yaml
selector:
  matchLabels:
    app: backend
rules:
  - to:
      - operation:
          methods: ["GET"]
          paths: ["/api/*"]
```

não deve permanecer assim em Ambient.

O status pode mostrar:

```text
ztunnel does not support HTTP attributes
```

Corrija usando `targetRefs` para o Service protegido.

## 8. Rollback Ambient → Sidecar

Remover enrollment:

```bash
kubectl label namespace istio-lab \
  istio.io/use-waypoint-

kubectl label namespace istio-lab \
  istio.io/dataplane-mode-
```

Reativar injection:

```bash
kubectl label namespace istio-lab \
  istio-injection=enabled
```

Recriar workloads:

```bash
kubectl rollout restart deployment -n istio-lab
```

Restaurar manifests Sidecar:

```text
VirtualService
DestinationRule
AuthorizationPolicy selector-based compatível
```

Valide:

```bash
kubectl get pods -n istio-lab
```

Esperado:

```text
2/2
```

## PRODUÇÃO

Migração segura exige:

- inventário;
- backup;
- compatibility review;
- observabilidade;
- rollout gradual;
- teste funcional;
- rollback ensaiado.

## Checkpoint

Migração de mesh não é apenas mudar labels.

Ela também pode exigir migração das **APIs e políticas** que dependem do dataplane.
