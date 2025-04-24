{{/*
Expand the name of the chart.
*/}}
{{- define "var.name" -}}
{{- default .Values.serviceName | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "var.fullname" -}}
{{ include "var.name" . }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "var.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "var.labels" -}}
helm.sh/chart: {{ include "var.chart" . }}
{{ include "var.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "var.selectorLabels" -}}
app.kubernetes.io/name: {{ include "var.name" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "var.serviceAccountName" -}}
{{- include "var.name" . }}
{{- end }}

{{/*
Create GCP service account principle
*/}}
{{- define "var.serviceAccountPrinciple" -}}
{{ include "var.serviceAccountName" . }}@{{ .Values.gcpProjectId }}.iam.gserviceaccount.com
{{- end }}

{{- define "mergeEnvironmentVariables" -}}
{{- $mainEnv := .mainEnv | default list -}}
{{- $initEnv := .initEnv | default list -}}
{{- $strategy := .strategy | default "mainOverrides" -}}

{{- if eq $strategy "mainOverrides" -}}
  {{- /* Convert init env to map for easier lookup */ -}}
  {{- $initEnvMap := dict -}}
  {{- range $initEnv -}}
    {{- $_ := set $initEnvMap .name . -}}
  {{- end -}}

  {{- /* Start with init env */ -}}
  {{- $result := $initEnv -}}

  {{- /* Add or override with main env */ -}}
  {{- range $mainEnv -}}
    {{- $result = append $result . -}}
  {{- end -}}

  {{- /* Remove duplicates (keeping main container values) */ -}}
  {{- $finalResult := list -}}
  {{- $seenNames := dict -}}
  {{- range $result | reverse -}}
    {{- if not (hasKey $seenNames .name) -}}
      {{- $finalResult = append $finalResult . -}}
      {{- $_ := set $seenNames .name "seen" -}}
    {{- end -}}
  {{- end -}}

  {{- $finalResult | reverse | toYaml -}}
{{- else if eq $strategy "initOverrides" -}}
  {{- /* Convert main env to map for easier lookup */ -}}
  {{- $mainEnvMap := dict -}}
  {{- range $mainEnv -}}
    {{- $_ := set $mainEnvMap .name . -}}
  {{- end -}}

  {{- /* Start with main env */ -}}
  {{- $result := $mainEnv -}}

  {{- /* Add or override with init env */ -}}
  {{- range $initEnv -}}
    {{- $result = append $result . -}}
  {{- end -}}

  {{- /* Remove duplicates (keeping init container values) */ -}}
  {{- $finalResult := list -}}
  {{- $seenNames := dict -}}
  {{- range $result | reverse -}}
    {{- if not (hasKey $seenNames .name) -}}
      {{- $finalResult = append $finalResult . -}}
      {{- $_ := set $seenNames .name "seen" -}}
    {{- end -}}
  {{- end -}}

  {{- $finalResult | reverse | toYaml -}}
{{- end -}}
{{- end -}}
