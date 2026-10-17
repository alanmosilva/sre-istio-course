# 11 — Istio em produção

## Objetivo

Transformar conhecimento de LAB em critérios de operação real.

## 1. Alta disponibilidade

Componentes críticos devem ser dimensionados para falhas.

Avalie:

```text
istiod
ingress gateways
egress gateways
waypoints
```

Valide distribuição:

```bash
kubectl get pods -n istio-system -o wide
```

Em AWS, considere múltiplas AZs.

## 2. Requests e limits

Exemplo:

```yaml
resources:
  requests:
    cpu: 500m
    memory: 512Mi
  limits:
    cpu: "2"
    memory: 2Gi
```

Não copie valores cegamente.

Dimensione usando:

- carga;
- throughput;
- latência;
- número de conexões;
- quantidade de configs;
- número de workloads.

## 3. PodDisruptionBudget

Exemplo conceitual:

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: istiod
  namespace: istio-system
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: istiod
```

PDB reduz impacto de disruptions voluntárias.

Não garante disponibilidade sozinho.

## 4. Gateway em HA

```text
AWS NLB
├── gateway-1
├── gateway-2
└── gateway-3
```

Avalie:

- replicas;
- HPA;
- topology spread;
- PDB;
- requests/limits.

## 5. Upgrade

Nunca faça upgrade de produção como simples:

```bash
istioctl upgrade -y
```

Fluxo esperado:

```text
compatibilidade
↓
backup
↓
canary/revision
↓
migração progressiva
↓
observação
↓
rollback
```

No Sidecar Mode, atualizar control plane não significa que todos os proxies já foram atualizados.

Valide:

```bash
istioctl proxy-status
```

## 6. Ambient

Ambient desacopla dataplane da aplicação, mas ainda existem componentes a operar:

```text
istiod
istio-cni
ztunnel
Waypoint
Gateway API
```

## 7. Segurança

Checklist mínimo:

- mTLS;
- ServiceAccounts dedicados;
- least privilege;
- AuthorizationPolicy;
- NetworkPolicy quando aplicável;
- secrets fora do Git;
- change review;
- auditoria.

## 8. Observabilidade

Monitore:

- 4xx/5xx;
- latency;
- request volume;
- saturation;
- proxy errors;
- control plane;
- gateways;
- waypoint;
- ztunnel.

## Checklist produção

```text
[ ] istiod HA
[ ] gateway HA
[ ] múltiplas AZs
[ ] requests/limits
[ ] PDB
[ ] HPA avaliado
[ ] mTLS definido
[ ] ServiceAccounts dedicados
[ ] AuthorizationPolicy revisada
[ ] observabilidade
[ ] plano de upgrade
[ ] plano de rollback
[ ] backup das configurações
[ ] cleanup documentado
```
