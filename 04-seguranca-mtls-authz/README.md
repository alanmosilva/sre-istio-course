# 04 — mTLS, identidade e AuthorizationPolicy

## Objetivo

Autenticar workloads e autorizar somente comunicações necessárias.

## 1. Identidade

No Istio, a identidade é baseada no ServiceAccount.

Exemplo SPIFFE:

```text
cluster.local/ns/istio-lab/sa/client-sa
```

## 2. mTLS

No mesh:

```text
client
  ↓ TLS autenticado mutuamente
backend
```

### PERMISSIVE

Aceita tráfego plaintext e mTLS.

Útil durante migração.

### STRICT

Exige mTLS.

Aplicar:

```bash
kubectl apply -f peer-authentication-strict.yaml
```

## 3. Workload fora do mesh

Crie o namespace:

```bash
kubectl create namespace legacy
kubectl apply -f legacy-client.yaml
```

Com `STRICT`, um cliente plaintext não deve conseguir falar diretamente com workloads protegidos conforme o caminho/política configurada.

## 4. AuthorizationPolicy

Exemplo: somente `client-sa` pode chamar backend:

```bash
kubectl apply -f authorization-policy-sidecar.yaml
```

## 5. L7

No Sidecar Mode podemos restringir:

```text
GET /api/*
```

e bloquear, por exemplo:

```text
POST /admin
```

## NetworkPolicy x AuthorizationPolicy

| Recurso | Camada |
|---|---|
| NetworkPolicy | L3/L4 |
| AuthorizationPolicy | identidade e, com proxy L7, HTTP/L7 |

Uma não substitui automaticamente a outra.

## Zero Trust

Não confie em um workload apenas porque ele está “dentro do cluster”.

Pergunte:

```text
Quem é?
Pode fazer o quê?
Para qual serviço?
Em qual operação?
```

## PRODUÇÃO

- ServiceAccounts dedicados;
- `STRICT` progressivo;
- least privilege;
- políticas versionadas em Git;
- teste negativo obrigatório;
- cuidado com `ALLOW`: depois que existe uma ALLOW policy aplicável, tudo que não casa com ela é negado.

## Checkpoint

Você deve distinguir:

```text
PeerAuthentication
→ autenticação/mTLS

AuthorizationPolicy
→ autorização
```
