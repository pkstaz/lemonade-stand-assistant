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

{{/*
Whether this release shares LLM/detectors from another namespace
*/}}
{{- define "assistant.sharedModelsEnabled" -}}
{{- if and .Values.models .Values.models.shared .Values.models.shared.enabled -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/*
Namespace that owns the shared LLM + HAP + prompt-injection (+ MinIO)
*/}}
{{- define "assistant.sharedModelsNamespace" -}}
{{- if and .Values.models .Values.models.shared .Values.models.shared.namespace -}}
{{- .Values.models.shared.namespace -}}
{{- else -}}
lemonade-stand-assistant
{{- end -}}
{{- end -}}

{{/*
Deploy in-cluster LLM in this release?
*/}}
{{- define "assistant.deployLlm" -}}
{{- if eq (include "assistant.sharedModelsEnabled" .) "true" -}}
false
{{- else if hasKey (.Values.models | default dict) "deployLlm" -}}
{{- .Values.models.deployLlm -}}
{{- else if .Values.model.endpoint -}}
false
{{- else -}}
true
{{- end -}}
{{- end -}}

{{/*
Deploy HAP + prompt-injection + MinIO in this release?
*/}}
{{- define "assistant.deployDetectors" -}}
{{- if eq (include "assistant.sharedModelsEnabled" .) "true" -}}
false
{{- else if hasKey (.Values.models | default dict) "deployDetectors" -}}
{{- .Values.models.deployDetectors -}}
{{- else -}}
true
{{- end -}}
{{- end -}}

{{/*
LLM hostname for orchestrator
*/}}
{{- define "assistant.llmHostname" -}}
{{- if .Values.model.endpoint -}}
{{- .Values.model.endpoint -}}
{{- else if eq (include "assistant.sharedModelsEnabled" .) "true" -}}
llama-32-predictor.{{ include "assistant.sharedModelsNamespace" . }}.svc.cluster.local
{{- else -}}
llama-32-predictor
{{- end -}}
{{- end -}}

{{/*
LLM port for orchestrator
*/}}
{{- define "assistant.llmPort" -}}
{{- if .Values.model.port -}}
{{- .Values.model.port -}}
{{- else -}}
8080
{{- end -}}
{{- end -}}

{{/*
HAP detector hostname
*/}}
{{- define "assistant.hapHostname" -}}
{{- if and .Values.detectors .Values.detectors.hap .Values.detectors.hap.hostname -}}
{{- .Values.detectors.hap.hostname -}}
{{- else if eq (include "assistant.sharedModelsEnabled" .) "true" -}}
guardrails-detector-ibm-hap-predictor.{{ include "assistant.sharedModelsNamespace" . }}.svc.cluster.local
{{- else -}}
guardrails-detector-ibm-hap-predictor
{{- end -}}
{{- end -}}

{{/*
Prompt-injection detector hostname
*/}}
{{- define "assistant.promptInjectionHostname" -}}
{{- if and .Values.detectors .Values.detectors.promptInjection .Values.detectors.promptInjection.hostname -}}
{{- .Values.detectors.promptInjection.hostname -}}
{{- else if eq (include "assistant.sharedModelsEnabled" .) "true" -}}
prompt-injection-detector-predictor.{{ include "assistant.sharedModelsNamespace" . }}.svc.cluster.local
{{- else -}}
prompt-injection-detector-predictor
{{- end -}}
{{- end -}}
