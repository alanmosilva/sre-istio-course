#!/usr/bin/env bash
set -euo pipefail

ISTIO_VERSION="${ISTIO_VERSION:-1.31.1}"

curl -L https://istio.io/downloadIstio \
  | ISTIO_VERSION="${ISTIO_VERSION}" TARGET_ARCH=x86_64 sh -

echo
echo "Istio baixado."
echo "Entre no diretório istio-${ISTIO_VERSION} e execute:"
echo "export PATH=\$PWD/bin:\$PATH"
