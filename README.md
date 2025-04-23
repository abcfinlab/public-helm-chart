# public-helm-chart

## Charts

### l7-services

The `l7-services` chart is designed to deploy services with various Kubernetes resources. It supports:

- Deployments
- Services
- Ingress
- HPA (Horizontal Pod Autoscaler)
- Service Accounts
- GCP resources (PubSub, Storage, IAM)
- CronJobs (as of v1.3.0)

#### CronJob Support

As of version 1.3.0, the chart supports creating Kubernetes CronJobs. This feature is disabled by default.

To enable CronJobs, set `cronJobs.enabled` to `true` and define your jobs under `cronJobs.jobs`:

```yaml
cronJobs:
  enabled: true
  jobs:
    - name: example-cronjob
      schedule: "*/5 * * * *"
      concurrencyPolicy: Forbid
      successfulJobsHistoryLimit: 3
      failedJobsHistoryLimit: 1
      restartPolicy: OnFailure
      command: ["python", "cronjob_script.py"]
      env:
        - name: ENV_VAR
          value: "value"
```

Each CronJob can be configured with:
- `name`: Name of the CronJob (required)
- `schedule`: Cron schedule expression (required)
- `concurrencyPolicy`: How to handle concurrent executions (Allow, Forbid, Replace)
- `successfulJobsHistoryLimit`: How many successful jobs to keep
- `failedJobsHistoryLimit`: How many failed jobs to keep
- `suspend`: Whether to suspend the CronJob
- `startingDeadlineSeconds`: Deadline for starting jobs
- `backoffLimit`: Number of retries before job is marked as failed
- `activeDeadlineSeconds`: Time limit for job execution
- `ttlSecondsAfterFinished`: Time to keep completed jobs
- `restartPolicy`: Pod restart policy (OnFailure, Never)
- `image`: Custom image for the CronJob (falls back to main chart image if not specified)
- `command`: Command to run
- `args`: Arguments for the command
- `env`: Environment variables
- `resources`: Resource requests and limits

## Release

⚠️ At the moment you have to increase the version in the file [Chart.yaml](./charts/l7-services/Chart.yaml) manually.
Otherwise, the release pipeline will fail.
