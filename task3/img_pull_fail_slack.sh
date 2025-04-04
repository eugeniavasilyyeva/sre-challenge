#!/bin/bash
# Should be replaced with actual Slack Incoming Webhook URL.
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX"
#Write to log
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}
# Slack message
send_slack_notification() {
    local pod_name="$1"
    local namespace="$2"
    local reason="$3"
    local timestamp
    timestamp=$(TZ=UTC date '+%Y-%m-%d %H:%M:%S UTC')

    curl -s -X POST -H 'Content-type: application/json' \
        --data "{
            \"text\": \"🚨 *Image Pull Failure Detected!*\nTime: $timestamp\nPod: \`$pod_name\`\nNamespace: \`$namespace\`\nReason: \`$reason\`\"
        }" \
        "$SLACK_WEBHOOK_URL" > /dev/null
}
# Check for Kubernetes events and filter for ImagePullBackOff or ErrImagePull reasons, write into log and trigger notification sending.
log "[INFO] Checking for image pull failures..."

kubectl get events -A -o json | jq -c '.items[]' | while read -r event; do
    reason=$(jq -r '.reason' <<< "$event")

    [[ "$reason" =~ ^(ImagePullBackOff|ErrImagePull)$ ]] || continue

    pod_name=$(jq -r '.involvedObject.name' <<< "$event")
    namespace=$(jq -r '.involvedObject.namespace' <<< "$event")

    log "⚠️ ALERT: Pod $pod_name in $namespace failed with $reason"
    send_slack_notification "$pod_name" "$namespace" "$reason"
done
