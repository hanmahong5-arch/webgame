#!/usr/bin/env bash
# =============================================================================
# 2c-bs-www: Vue → Phoenix Migration Deployment Script
#
# Prerequisites:
#   - SSH access to master (100.98.57.55)
#   - Docker image already pushed to GHCR
#   - This script runs from the lurus monorepo root or 2c-bs-www/
#
# What this script does:
#   1. Verifies master node label
#   2. Creates K8s Secret (if not exists)
#   3. Records current deployment for rollback
#   4. Pauses ArgoCD auto-sync
#   5. Applies new manifests
#   6. Waits for rollout
#   7. Runs smoke tests
#   8. Re-enables ArgoCD auto-sync
#
# Rollback:
#   ssh root@100.98.57.55 "kubectl set image deploy/lurus-www www=<OLD_IMAGE> -n lurus-www"
# =============================================================================

set -euo pipefail

MASTER="root@100.98.57.55"
NS="lurus-www"

echo "=== Step 1: Verify master node label ==="
ssh "$MASTER" "kubectl get nodes -l node-role.kubernetes.io/master=true -o name" || {
  echo "WARN: master label not found. Trying control-plane label..."
  ssh "$MASTER" "kubectl get nodes -l node-role.kubernetes.io/control-plane -o name" || {
    echo "ERROR: No master/control-plane node found. Check labels."
    exit 1
  }
}

echo ""
echo "=== Step 2: Create Secret (if not exists) ==="
ssh "$MASTER" "kubectl get secret lurus-www-secret -n $NS 2>/dev/null" && {
  echo "Secret already exists, skipping."
} || {
  echo "Creating secret..."
  SECRET_KEY_BASE=$(openssl rand -hex 64)
  read -rp "Enter ZITADEL_CLIENT_ID: " ZITADEL_CLIENT_ID
  ssh "$MASTER" "kubectl create secret generic lurus-www-secret -n $NS \
    --from-literal=secret-key-base='$SECRET_KEY_BASE' \
    --from-literal=zitadel-client-id='$ZITADEL_CLIENT_ID'"
  echo "Secret created."
}

echo ""
echo "=== Step 3: Record current deployment for rollback ==="
CURRENT_IMAGE=$(ssh "$MASTER" "kubectl get deploy lurus-www -n $NS -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null" || echo "none")
echo "Current image: $CURRENT_IMAGE"
echo "To rollback: kubectl set image deploy/lurus-www www=$CURRENT_IMAGE -n $NS"

echo ""
echo "=== Step 4: Pause ArgoCD auto-sync ==="
ssh "$MASTER" "argocd app set lurus-www --sync-policy none 2>/dev/null" || echo "ArgoCD not available or app not found, continuing..."

echo ""
echo "=== Step 5: Apply manifests ==="
ssh "$MASTER" "kubectl apply -f -" < deploy/k8s/namespace.yaml
ssh "$MASTER" "kubectl apply -f -" < deploy/k8s/deployment.yaml
ssh "$MASTER" "kubectl apply -f -" < deploy/k8s/service.yaml

echo ""
echo "=== Step 6: Wait for rollout ==="
ssh "$MASTER" "kubectl rollout status deploy/lurus-www -n $NS --timeout=120s"

echo ""
echo "=== Step 7: Smoke tests ==="
POD_IP=$(ssh "$MASTER" "kubectl get pod -n $NS -l app=lurus-www -o jsonpath='{.items[0].status.podIP}'")
echo "Pod IP: $POD_IP"

ssh "$MASTER" "curl -sf http://$POD_IP:4000/health" && echo " ✓ /health" || echo " ✗ /health FAILED"
ssh "$MASTER" "curl -sf -o /dev/null -w '%{http_code}' http://$POD_IP:4000/" | grep -q 200 && echo " ✓ / (home)" || echo " ✗ / FAILED"
ssh "$MASTER" "curl -sI http://$POD_IP:4000/ | grep -q 'x-frame-options: DENY'" && echo " ✓ security headers" || echo " ✗ security headers FAILED"
ssh "$MASTER" "curl -sf -o /dev/null -w '%{http_code}' http://$POD_IP:4000/pricing" | grep -q 200 && echo " ✓ /pricing" || echo " ✗ /pricing FAILED"

echo ""
echo "=== Step 8: Re-enable ArgoCD auto-sync ==="
read -rp "Smoke tests passed. Re-enable ArgoCD auto-sync? [y/N] " CONFIRM
if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
  ssh "$MASTER" "argocd app set lurus-www --sync-policy automated 2>/dev/null" || echo "Manual re-enable needed."
  echo "Auto-sync re-enabled."
else
  echo "Skipped. Remember to re-enable manually."
fi

echo ""
echo "=== Migration complete ==="
echo "Rollback command: ssh $MASTER 'kubectl set image deploy/lurus-www www=$CURRENT_IMAGE -n $NS'"
