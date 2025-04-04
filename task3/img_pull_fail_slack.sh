#!/bin/bash

# Exit the script immediately if any command fails
set -e  

# Should be replaced with actual Slack Incoming Webhook URL.
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX"

# Slack message
function send_slack_notification() {
    local pod_name="$1"
    local namespace="$2"
    local reason="$3"
    local message="$4"
	  local timestamp
    timestamp=$(TZ=UTC date '+%Y-%m-%d %H:%M:%S UTC')  # Current UTC timestamp

    curl -X POST -H 'Content-type: application/json' \
        --data "{
            \"text\": \"🚨 *Image Pull Failure Detected!*\nPod: \`$pod_name\`\nNamespace: \`$namespace\`\nReason: \`$reason\`\nMessage: $message\"
        }" \
        "$SLACK_WEBHOOK_URL"
}

# Watch for Kubernetes events in real-time and filter for ImagePullBackOff or ErrImagePull reasons.
kubectl get events --all-namespaces --watch --output-watch-events | while read -r line; do
    # Filter for image pull failures
    if echo "$line" | grep -q -E 'ImagePullBackOff|ErrImagePull'; then
        # Extract relevant information using awk
        namespace=$(echo "$line" | awk '{print $2}')
        pod_name=$(echo "$line" | awk '{print $4}')
        reason=$(echo "$line" | grep -oE 'ImagePullBackOff|ErrImagePull')
        message=$(echo "$line" | cut -d' ' -f6-)

        # Call the Slack notifier
        send_slack_notification "$pod_name" "$namespace" "$reason" "$message" 
    fi
done
