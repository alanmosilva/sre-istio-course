# 07 — Egress, ServiceEntry e Egress Gateway

## Objetivo

Entender como o mesh trata destinos externos.

## 1. ALLOW_ANY

Comportamento padrão comum:

```text
workload
→ destino externo
```

mesmo que o destino não esteja registrado explicitamente.

## 2. REGISTRY_ONLY

Edite a configuração do mesh de forma declarativa conforme seu método de instalação.

Conceito:

```yaml
outboundTrafficPolicy:
  mode: REGISTRY_ONLY
```

Depois, destinos externos precisam estar registrados.

> `REGISTRY_ONLY` não deve ser tratado como firewall de segurança completo.

## 3. ServiceEntry

Aplicar:

```bash
kubectl apply -f service-entry-httpbin.yaml
```

ServiceEntry informa ao Istio sobre um serviço externo.

Ele não transforma o destino em um serviço interno.

## 4. Egress Gateway

Instalar:

```bash
istioctl install -f egress.yaml -y
```

Não use `kubectl apply -f egress.yaml` neste fluxo.

Aplique:

```bash
kubectl apply -f egress-gateway.yaml
kubectl apply -f virtual-service-egress.yaml
```

Fluxo:

```text
client
↓
sidecar
↓
egress gateway
↓
httpbin.org
```

## Importante

Não use neste LAB uma combinação simplista de:

```text
PASSTHROUGH
+
AuthorizationPolicy baseada na identidade original do client
+
DestinationRule ISTIO_MUTUAL para o gateway
```

Essa topologia pode fazer o gateway enxergar identidade/camada diferente da esperada e gerar erros como:

```text
filter_chain_not_found
TLS EOF
```

Neste curso o objetivo é provar o caminho pelo Egress Gateway.

Controle de egress de produção normalmente envolve arquitetura e controles adicionais.

## PRODUÇÃO

ServiceEntry não é firewall.

Combine conforme necessidade:

- NetworkPolicy;
- firewall/NAT;
- AWS Network Firewall;
- proxy de egress;
- DNS controls;
- políticas no mesh;
- observabilidade.

## Checkpoint

```text
ServiceEntry
→ registra destino externo

Egress Gateway
→ centraliza caminho de saída
```
