# Kubernetes Image Pull Failure Alert

This script automatically checks for image pull errors in Kubernetes and sends a notification to Slack if such errors are detected.
Note: I am not familiar with Slack, because never used it before. So this script may need some updates after testing with real case

## Description

The script checks Kubernetes events for image pull failures (e.g., `ImagePullBackOff` or `ErrImagePull`). If any errors are found, it sends a Slack notification with the error details.

## Requirements

- `kubectl` to access your Kubernetes cluster
- `jq` for parsing JSON data
- Configured Slack Webhook to receive notifications

## Setup

1. Get your Slack Webhook URL. Create an Incoming Webhook in Slack if you haven't already, and copy the URL.
2. Edit the `SLACK_WEBHOOK_URL` variable in the script to include real Slack Webhook URL:
   ```bash
   SLACK_WEBHOOK_URL="https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX"
3. Script is not looped. Did it intentionally to allow usage by demand and allow possibility to automate it by creating CronJob. 
