# 03 — Traffic Management

## Objetivo

Controlar tráfego entre versões sem alterar o código da aplicação.

## Recursos principais

```text
VirtualService
→ regras de roteamento

DestinationRule
→ subsets e políticas do destino
```

## 1. Subsets

Aplicar:

```bash
kubectl apply -f destination-rule.yaml
```

## 2. Canary 90/10

```bash
kubectl apply -f virtual-service-90-10.yaml
```

Teste várias vezes:

```bash
for i in {1..30}; do
  kubectl exec -n istio-lab client -- \
    curl -s http://backend
done
```

## 3. Header routing

```bash
kubectl apply -f virtual-service-header.yaml
```

Teste:

```bash
kubectl exec -n istio-lab client -- \
  curl -s -H 'x-version: v2' http://backend
```

## 4. Timeout

Timeout impede que uma dependência lenta consuma recursos indefinidamente.

Exemplo:

```yaml
timeout: 2s
```

Em produção, timeout deve ser escolhido com base em SLO, latência da dependência e comportamento da aplicação.

## 5. Retry

Retry pode aumentar disponibilidade, mas também pode piorar incidentes.

Use especialmente em operações idempotentes.

Pergunte antes:

```text
Se eu repetir a requisição, posso duplicar uma transação?
```

## 6. Fault injection

Útil para testar resiliência:

```yaml
fault:
  delay:
    percentage:
      value: 100
    fixedDelay: 3s
```

ou:

```yaml
fault:
  abort:
    percentage:
      value: 100
    httpStatus: 500
```

## 7. Circuit breaking

Exemplo de `DestinationRule`:

```yaml
trafficPolicy:
  connectionPool:
    tcp:
      maxConnections: 10
    http:
      http1MaxPendingRequests: 5
      maxRequestsPerConnection: 10
  outlierDetection:
    consecutive5xxErrors: 3
    interval: 5s
    baseEjectionTime: 30s
    maxEjectionPercent: 50
```

## PRODUÇÃO

Não aplique retry + timeout + circuit breaker “porque parece boa prática”.

Eles alteram o comportamento distribuído da aplicação.

Observe:

- taxa de erro;
- latência;
- volume de retry;
- saturação;
- efeito sobre downstream.

## Troubleshooting

```bash
istioctl proxy-config routes deploy/client -n istio-lab
istioctl proxy-config clusters deploy/client -n istio-lab
istioctl proxy-config endpoints deploy/client -n istio-lab
```

## Checkpoint

Entenda a diferença:

```text
Service
→ descoberta lógica do backend

VirtualService
→ como rotear

DestinationRule
→ subsets e política do destino
```
