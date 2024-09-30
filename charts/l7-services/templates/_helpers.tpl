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
