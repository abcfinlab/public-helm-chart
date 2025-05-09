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

#### Merging Envs

As of version 1.4.0, the chart supports merging the normal container envs with the initContainers or cronJobs envs.

To enable merge env, first set `envMerging.enabled` to `true` and define your stategy `envMerging.strategy`. (global option)

Available stategies are:
- mainOverrides (default)
- initOverrides

You can then enable the merging of the environment variables separately for each cron job or inti container.

Working example:
```yaml
l7-service:
  image:
    repository: &repo "europe-west3-docker.pkg.dev/common-l7/lease-seven-images/bankdata-service"
    #x-release-please-start-version
    tag: &tag '1.2.1'
    #x-release-please-end
  envMerging:
    enabled: true
    strategy: "mainOverrides"

  initContainers:
    - name: db-migration
      mergeEnv: true # ✅ Add this flag to enable env merge
      image:
        repository: *repo
        tag: *tag
      env:
        - name: FLYWAY_ENABLED
          value: "true"
        - name: SPRING_WEB_APP_TYPE
          value: "none"
    - name: bankdata-sync
      mergeEnv: true # ✅ Add this flag to enable env merge
      image:
        repository: *repo
        tag: *tag
      env:
        - name: ABCFINLAB_FEDERAL_BANK_INIT_SYNC
          value: "true"
  cronJobs:
    enabled: true
    jobs:
      - name: bankdata-sync
        mergeEnv: true # ✅ Add this flag to enable env merge
        schedule: "0 0 * * *"
        concurrencyPolicy: Forbid
        successfulJobsHistoryLimit: 3
        failedJobsHistoryLimit: 1
        restartPolicy: Never
        image:
          repository: *repo
          tag: *tag
        env:
          - name: ABCFINLAB_FEDERAL_BANK_INIT_SYNC
            value: "true"
  serviceName: bankdata-service
  nodeSelector:
    topology.kubernetes.io/zone: "europe-west3-a"
  databases:
    - name: bankdata_service
      instanceName: lease-seven
  projectIamRoles:
    - roles/cloudsql.client
    - roles/cloudsql.instanceUser
  resources:
    limits:
      cpu: 500m
      memory: 2Gi
    requests:
      cpu: 500m
      memory: 2Gi
  readinessProbe:
    failureThreshold: 2
    httpGet:
      path: /bankdata-service/actuator/health
      port: 8080
    initialDelaySeconds: 10
    periodSeconds: 15
    successThreshold: 2
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

#### Merging Envs

As of version 1.4.0, the chart supports merging the normal container envs with the initContainers or cronJobs envs.

To enable merge env, first set `envMerging.enabled` to `true` and define your stategy `envMerging.strategy`. (global option)

Available stategies are:
- mainOverrides (default)
- initOverrides

You can then enable the merging of the environment variables separately for each cron job or inti container.

Working example:
```yaml
l7-service:
  image:
    repository: &repo "europe-west3-docker.pkg.dev/common-l7/lease-seven-images/bankdata-service"
    #x-release-please-start-version
    tag: &tag '1.2.1'
    #x-release-please-end
  envMerging:
    enabled: true
    strategy: "mainOverrides"

  initContainers:
    - name: db-migration
      mergeEnv: true # ✅ Add this flag to enable env merge
      image:
        repository: *repo
        tag: *tag
      env:
        - name: FLYWAY_ENABLED
          value: "true"
        - name: SPRING_WEB_APP_TYPE
          value: "none"
    - name: bankdata-sync
      mergeEnv: true # ✅ Add this flag to enable env merge
      image:
        repository: *repo
        tag: *tag
      env:
        - name: ABCFINLAB_FEDERAL_BANK_INIT_SYNC
          value: "true"
  cronJobs:
    enabled: true
    jobs:
      - name: bankdata-sync
        mergeEnv: true # ✅ Add this flag to enable env merge
        schedule: "0 0 * * *"
        concurrencyPolicy: Forbid
        successfulJobsHistoryLimit: 3
        failedJobsHistoryLimit: 1
        restartPolicy: Never
        image:
          repository: *repo
          tag: *tag
        env:
          - name: ABCFINLAB_FEDERAL_BANK_INIT_SYNC
            value: "true"
  serviceName: bankdata-service
  nodeSelector:
    topology.kubernetes.io/zone: "europe-west3-a"
  databases:
    - name: bankdata_service
      instanceName: lease-seven
  projectIamRoles:
    - roles/cloudsql.client
    - roles/cloudsql.instanceUser
  resources:
    limits:
      cpu: 500m
      memory: 2Gi
    requests:
      cpu: 500m
      memory: 2Gi
  readinessProbe:
    failureThreshold: 2
    httpGet:
      path: /bankdata-service/actuator/health
      port: 8080
    initialDelaySeconds: 10
    periodSeconds: 15
    successThreshold: 2
```

## Release

⚠️ At the moment you have to increase the version in the file [Chart.yaml](./charts/l7-services/Chart.yaml) manually.
Otherwise, the release pipeline will fail.
