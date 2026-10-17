# 06 — Telemetria e diagnóstico do Istio

## Objetivo

Aprender a usar sinais do próprio Istio para localizar problemas.

Este módulo **não é um curso de observabilidade**.

## 1. Prometheus addon

No diretório do Istio:

```bash
kubectl apply -f samples/addons/prometheus.yaml
```

Métrica importante:

```text
istio_requests_total
```

Ela permite responder:

- quem chamou;
- qual destino;
- status HTTP;
- volume;
- versão do workload.

## 2. Access logs

```bash
kubectl logs \
  -n istio-lab \
  <POD> \
  -c istio-proxy
```

Exemplo:

```text
"GET /api/v1 HTTP/1.1" 200 - via_upstream ...
```

O formato padrão é **posicional**.

Nesse trecho:

```text
200
```

é o response code.

```text
-
```

é o `response_flags`: nenhum erro especial do proxy.

```text
via_upstream
```

é informação sobre o detalhe/origem da resposta.

Flags comuns:

| Flag | Ideia geral |
|---|---|
| `UH` | no healthy upstream |
| `UF` | upstream connection failure |
| `NR` | no route |
| `UO` | upstream overflow |

## 3. Kiali

```bash
kubectl apply -f samples/addons/kiali.yaml
```

Acesse:

```bash
istioctl dashboard kiali
```

Kiali ajuda a localizar relações e sintomas.

Ele **não substitui**:

```text
istioctl
Envoy logs
kubectl
métricas
```

## 4. Sequência para investigar 503

```text
proxy-status
↓
routes
↓
clusters
↓
endpoints
↓
access logs
↓
métricas/Kiali
```

## PRODUÇÃO

Configure retenção, dashboards, alertas e tracing em plataforma de observabilidade apropriada.

O addon do curso é LAB.

## Checkpoint

Você deve conseguir interpretar pelo menos:

```text
200 -
503 UH
503 UF
404/503 NR
```
