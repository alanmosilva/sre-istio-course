# Checklist do curso

## Fundamentos

- [ ] Explico o que é Service Mesh
- [ ] Diferencio control plane e data plane
- [ ] Explico por que Kubernetes Service continua existindo
- [ ] Diferencio Sidecar e Ambient

## Sidecar / Envoy

- [ ] Instalo Istio com istioctl
- [ ] Habilito sidecar injection
- [ ] Entendo Listener → Route → Cluster → Endpoint
- [ ] Uso proxy-status
- [ ] Uso proxy-config

## Traffic Management

- [ ] VirtualService
- [ ] DestinationRule
- [ ] subsets
- [ ] weighted routing
- [ ] header routing
- [ ] timeout
- [ ] retry
- [ ] fault injection
- [ ] circuit breaking

## Segurança

- [ ] mTLS
- [ ] PERMISSIVE x STRICT
- [ ] PeerAuthentication
- [ ] ServiceAccount
- [ ] SPIFFE identity
- [ ] AuthorizationPolicy
- [ ] L4 x L7

## Ingress

- [ ] Istio Ingress Gateway
- [ ] AWS NLB
- [ ] internet-facing x internal
- [ ] HTTPS
- [ ] TLS secret
- [ ] /etc/hosts no LAB
- [ ] Gateway API
- [ ] HTTPRoute

## Telemetria

- [ ] istio_requests_total
- [ ] Envoy access log
- [ ] response_flags
- [ ] Kiali
- [ ] sequência de troubleshooting 503

## Egress

- [ ] ALLOW_ANY
- [ ] REGISTRY_ONLY
- [ ] ServiceEntry
- [ ] Egress Gateway
- [ ] TLS passthrough

## Ambient

- [ ] istio-cni
- [ ] ztunnel
- [ ] HBONE
- [ ] Waypoint
- [ ] namespace enrollment
- [ ] targetRefs
- [ ] HTTPRoute
- [ ] Services separados por versão

## Migração

- [ ] backup
- [ ] Sidecar → Ambient
- [ ] migro L7 policies
- [ ] migro traffic management
- [ ] removo injection
- [ ] valido 1/1
- [ ] sei fazer rollback

## Troubleshooting

- [ ] curl exit 6
- [ ] 503 UH
- [ ] UF
- [ ] NR
- [ ] RBAC access denied
- [ ] mTLS incompatível
- [ ] Waypoint não PROGRAMMED

## Produção

- [ ] HA
- [ ] requests/limits
- [ ] PDB
- [ ] múltiplas AZs
- [ ] upgrade seguro
- [ ] rollback
- [ ] observabilidade
- [ ] segurança

## Cleanup

- [ ] removi Gateway API owners
- [ ] removi Waypoints
- [ ] removi ingress gateway
- [ ] removi egress gateway
- [ ] removi namespaces
- [ ] removi Istio
- [ ] não há Services LoadBalancer
- [ ] não há NLB do LAB
- [ ] executei terraform destroy
