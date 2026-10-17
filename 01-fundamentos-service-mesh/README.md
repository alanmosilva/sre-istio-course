# 01 — Fundamentos de Service Mesh e Istio

## Objetivo

Entender por que um Service Mesh existe antes de instalar qualquer componente.

## 1. Kubernetes sem Istio

Fluxo básico:

```text
client
  ↓
Service
  ↓
EndpointSlice
  ↓
backend Pod
```

Kubernetes resolve:

- Service Discovery;
- balanceamento L4;
- DNS;
- endpoints;
- scheduling.

Mas não entrega sozinho, de forma padronizada entre aplicações:

- mTLS;
- identidade de workload;
- retries consistentes;
- timeout centralizado;
- autorização L7;
- traffic splitting avançado;
- telemetria uniforme.

## 2. O que é Service Mesh

É uma camada de infraestrutura para controlar comunicação entre workloads.

Em vez de cada aplicação implementar TLS, retry, tracing e autorização de maneira diferente, o mesh fornece essas funções no dataplane.

## 3. Istio

Principais componentes:

### Control Plane

`istiod`

Responsável por distribuir configuração, certificados, descoberta e políticas.

### Data Plane

Sidecar Mode:

```text
Pod
├── aplicação
└── Envoy
```

Ambient:

```text
Node
└── ztunnel

L7 opcional:
Waypoint
```

## 4. O que o Istio não substitui

Istio não substitui:

- Kubernetes Service;
- DNS;
- aplicação saudável;
- NetworkPolicy;
- WAF;
- firewall;
- observabilidade completa;
- API Gateway em todos os casos.

## 5. Sidecar x Ambient

| Característica | Sidecar | Ambient |
|---|---|---|
| proxy por Pod | sim | não |
| L4 | Envoy | ztunnel |
| L7 | Envoy | Waypoint |
| Pod típico | 2/2 | 1/1 |
| upgrade dataplane | reinjeção/restart | desacoplado da app |
| maturidade operacional | muito consolidada | arquitetura mais recente |

## PRODUÇÃO

Antes de adotar Istio, responda:

1. Qual problema real ele resolve?
2. A organização precisa de mesh?
3. A equipe sabe operar Envoy/Istio?
4. O overhead e a complexidade compensam?
5. Gateway/API Gateway já resolve o caso?

Nem toda empresa precisa de Service Mesh.

## Checkpoint

Você deve conseguir responder:

- diferença entre control plane e data plane;
- por que Kubernetes Service continua existindo;
- diferença conceitual entre Sidecar e Ambient;
- qual problema o mesh resolve.
