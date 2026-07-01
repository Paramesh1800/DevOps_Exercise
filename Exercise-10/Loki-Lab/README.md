# Exercise 10 – Loki Logging Failure

## Overview

This exercise demonstrates how to troubleshoot a logging pipeline using Grafana Alloy, Loki, and Grafana. The objective is to identify where logs stop flowing and determine the root cause of the issue.

The logging pipeline used in this lab is:

Application
↓
Grafana Alloy
↓
Loki
↓
Grafana

During the incident, the application continued to generate logs, but they were no longer visible in Grafana. The investigation focused on tracing the log flow through each component to identify where the failure occurred.

--------------------------------------------------

## Incident

Application logs stopped appearing in Grafana.

Observed Errors:

Alloy Logs

failed to push logs

HTTP 403

Loki Logs

authentication failed

--------------------------------------------------

## Objective

The objective of this exercise is to investigate the logging pipeline and determine the exact component where the failure occurs.

The investigation includes:

• Verifying that the application is generating logs.
• Confirming that Alloy is collecting logs.
• Checking whether Alloy is successfully sending logs to Loki.
• Verifying if Loki is accepting or rejecting incoming logs.
• Ensuring Grafana can query and display logs from Loki.

--------------------------------------------------

## Environment

• Docker Desktop
• Docker Compose
• Grafana
• Loki
• Grafana Alloy
• Windows Command Prompt

--------------------------------------------------

## Troubleshooting Process

### Step 1 – Verify the Application

The first step is to ensure the application is actively generating logs.

If the application is not producing logs, there will be no data available for the remaining components in the pipeline.

--------------------------------------------------

### Step 2 – Verify Alloy

Next, inspect the Alloy container logs.

The goal is to confirm that Alloy is reading the application log file and attempting to forward logs to Loki.

During this exercise, Alloy reported:

failed to push logs

This indicates that log collection is working, but forwarding the logs to Loki has failed.

--------------------------------------------------

### Step 3 – Verify Loki

Review the Loki container logs.

Loki reported:

authentication failed

This confirms that Loki received the request but rejected it because the authentication or configuration was incorrect.

--------------------------------------------------

### Step 4 – Verify Grafana

Open Grafana and navigate to the Explore page.

No new logs appear because Loki never stored them after rejecting the incoming requests from Alloy.

--------------------------------------------------

## Root Cause Analysis

The investigation confirmed the following:

• The application successfully generated logs.
• Alloy successfully collected the logs.
• Alloy failed while pushing logs to Loki.
• Loki rejected the incoming requests due to an authentication failure.
• Since Loki did not store the logs, Grafana could not display them.

The failure occurred between Alloy and Loki.

--------------------------------------------------

## Impact

• Application logs were unavailable in Grafana.
• Monitoring and troubleshooting became difficult.
• Engineers were unable to view real-time application logs.
• Incident analysis was delayed because logs were not being stored.

--------------------------------------------------

## Resolution

The issue can be resolved by:

• Verifying the Alloy configuration.
• Confirming the correct Loki endpoint.
• Validating authentication credentials.
• Ensuring the required permissions are configured.
• Restarting Alloy after updating the configuration.
• Verifying that logs are successfully ingested into Loki.

--------------------------------------------------

## Verification

After fixing the configuration:

• Alloy should successfully push logs to Loki.
• Loki should accept and store incoming logs.
• Grafana should immediately display new log entries.
• The logging pipeline should function normally.

--------------------------------------------------

## Key Learning Outcomes

This exercise helped reinforce the following concepts:

• Understanding the complete logging pipeline.
• Identifying failures by tracing log flow between components.
• Reading Alloy and Loki logs for troubleshooting.
• Diagnosing authentication and connectivity issues.
• Validating end-to-end log ingestion.
• Following a structured troubleshooting approach for observability platforms.

--------------------------------------------------

## Conclusion

The logging issue was traced by following the complete path from the application to Grafana. The application continued to generate logs, and Alloy successfully collected them. However, Alloy was unable to forward the logs because Loki rejected the requests due to an authentication failure. As a result, Grafana had no log data to display.

This exercise demonstrates the importance of tracing each component in a logging pipeline rather than assuming the issue exists at the application level. A systematic approach helps quickly identify the failure point and restore observability.
