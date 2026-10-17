# Versões de referência

| Componente | Versão usada |
|---|---|
| Istio | 1.31.1 |
| Gateway API | v1.6.0 |
| curl image | curlimages/curl:8.10.1 |
| http-echo | hashicorp/http-echo:1.0 |

## Istio

Instalação:

```bash
curl -L https://istio.io/downloadIstio \
  | ISTIO_VERSION=1.31.1 TARGET_ARCH=x86_64 sh -
```

## Gateway API

```bash
kubectl kustomize \
  "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v1.6.0" \
  | kubectl apply -f -
```

## Observação

Antes de usar em produção, verifique:

- support matrix Istio x Kubernetes;
- release notes;
- mudanças em APIs Beta/Alpha;
- compatibilidade com sua versão do EKS.
