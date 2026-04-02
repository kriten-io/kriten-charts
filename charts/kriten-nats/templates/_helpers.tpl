{{/*
Expand the name of the chart.
*/}}
{{- define "kriten-nats.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "kriten-nats.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "kriten-nats.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "kriten-nats.labels" -}}
helm.sh/chart: {{ include "kriten-nats.chart" . }}
{{ include "kriten-nats.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "kriten-nats.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kriten-nats.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Only need to provide a hostname if using an external postgres installation.
*/}}
{{- define "kriten-nats.dbHost" -}}
{{- if .Values.postgresql.install }}
  {{- .Release.Name }}-postgresql
{{- else }}
  {{- .Values.postgresql.host }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "kriten-nats.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "kriten-nats.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
