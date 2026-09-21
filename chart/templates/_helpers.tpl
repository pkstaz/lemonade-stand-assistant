{{/*
Return the active demo variant
*/}}
{{- define "assistant.variant" -}}
{{- .Values.variant | default "lemonade" -}}
{{- end -}}

{{/*
Application resource name based on variant
*/}}
{{- define "assistant.appName" -}}
{{- if .Values.app.name -}}
{{- .Values.app.name -}}
{{- else -}}
{{- $v := include "assistant.variant" . -}}
{{- if eq $v "lemonade" -}}lemonade-stand
{{- else if eq $v "cafe" -}}asistente-cafe
{{- else if eq $v "mate" -}}asistente-mate
{{- else if eq $v "piscola" -}}asistente-piscola
{{- else if eq $v "coffee" -}}coffee-assistant
{{- else if eq $v "cachaca" -}}assistente-cachaca
{{- else if eq $v "cafept" -}}assistente-cafe
{{- else -}}lemonade-stand
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Path prefix for variant-specific chart files (organized by language)
*/}}
{{- define "assistant.filesPath" -}}
{{- $v := include "assistant.variant" . -}}
{{- if eq $v "lemonade" -}}files/lemonade
{{- else if eq $v "cafe" -}}files/es/cafe
{{- else if eq $v "mate" -}}files/es/mate
{{- else if eq $v "piscola" -}}files/es/piscola
{{- else if eq $v "coffee" -}}files/en/coffee
{{- else if eq $v "cachaca" -}}files/pt/cachaca
{{- else if eq $v "cafept" -}}files/pt/cafe
{{- else -}}files/lemonade
{{- end -}}
{{- end -}}

{{/*
Target language for Lingua detector
*/}}
{{- define "assistant.targetLanguage" -}}
{{- $v := include "assistant.variant" . -}}
{{- if or (eq $v "lemonade") (eq $v "coffee") -}}
ENGLISH
{{- else if or (eq $v "cachaca") (eq $v "cafept") -}}
PORTUGUESE
{{- else -}}
SPANISH
{{- end -}}
{{- end -}}

{{/*
Namespace for the active variant
*/}}
{{- define "assistant.namespace" -}}
{{- if .Values.namespace.name -}}
{{- .Values.namespace.name -}}
{{- else -}}
{{- $v := include "assistant.variant" . -}}
{{- if eq $v "lemonade" -}}lemonade-stand-assistant
{{- else if eq $v "cafe" -}}asistente-cafe
{{- else if eq $v "mate" -}}asistente-mate
{{- else if eq $v "piscola" -}}asistente-piscola
{{- else if eq $v "coffee" -}}coffee-assistant
{{- else if eq $v "cachaca" -}}assistente-cachaca
{{- else if eq $v "cafept" -}}assistente-cafe
{{- else -}}lemonade-stand-assistant
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Helm release name (defaults to namespace)
*/}}
{{- define "assistant.releaseName" -}}
{{- if .Values.releaseName -}}
{{- .Values.releaseName -}}
{{- else -}}
{{- include "assistant.namespace" . -}}
{{- end -}}
{{- end -}}
