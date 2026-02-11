#!/bin/bash
# Script to create Alertmanager secrets for SMTP and Slack

set -e

NAMESPACE="monitoring"
SMTP_SECRET="alertmanager-smtp"
SLACK_SECRET="alertmanager-slack"

echo "=========================================="
echo "Setting up Alertmanager Secrets"
echo "=========================================="
echo ""

# Check if namespace exists
if ! kubectl get namespace "$NAMESPACE" &> /dev/null; then
    echo "Creating namespace: $NAMESPACE"
    kubectl create namespace "$NAMESPACE"
fi

# SMTP Secret
echo "Setting up SMTP secret..."
read -p "SMTP Email: " SMTP_EMAIL
read -sp "SMTP Password (App Password for Gmail): " SMTP_PASSWORD
echo ""
read -p "SMTP Server [smtp.gmail.com:587]: " SMTP_SERVER
SMTP_SERVER=${SMTP_SERVER:-smtp.gmail.com:587}

# Create SMTP secret
kubectl create secret generic "$SMTP_SECRET" \
  --from-literal=smtp_password="$SMTP_PASSWORD" \
  --namespace="$NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "✓ SMTP secret created"

# Slack Secret
echo ""
echo "Setting up Slack secret..."
read -p "Slack Webhook URL: " SLACK_WEBHOOK

# Create Slack secret
kubectl create secret generic "$SLACK_SECRET" \
  --from-literal=webhook_url="$SLACK_WEBHOOK" \
  --namespace="$NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "✓ Slack secret created"
echo ""
echo "=========================================="
echo "Secrets setup complete!"
echo "=========================================="
echo ""
echo "Note: Update prometheus/values.yaml with:"
echo "  - smtp_from: $SMTP_EMAIL"
echo "  - smtp_auth_username: $SMTP_EMAIL"
echo "  - smtp_smarthost: $SMTP_SERVER"
echo ""
