{{/*
Return the active demo variant
  Original: lemonade
  Alternatives: lang-theme (en-coffee, es-cafe, pt-cafe, ...)
*/}}
{{- define "assistant.variant" -}}
{{- .Values.variant | default "lemonade" -}}
{{- end -}}

{{/*
Application resource name based on variant
  lemonade     -> lemonade-stand (unchanged original)
  alternatives -> <variant>-stand (e.g. es-cafe-stand)
*/}}
{{- define "assistant.appName" -}}
{{- if .Values.app.name -}}
{{- .Values.app.name -}}
{{- else -}}
{{- $v := include "assistant.variant" . -}}
{{- if eq $v "lemonade" -}}
lemonade-stand
{{- else -}}
{{- printf "%s-stand" $v -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Path prefix for variant-specific chart files
  lemonade      -> files/lemonade
  en-coffee     -> files/en/coffee
  es-cafe       -> files/es/cafe
  pt-cachaca    -> files/pt/cachaca
*/}}
{{- define "assistant.filesPath" -}}
{{- $v := include "assistant.variant" . -}}
{{- if eq $v "lemonade" -}}
files/lemonade
{{- else -}}
{{- $parts := splitList "-" $v -}}
{{- if lt (len $parts) 2 -}}
files/lemonade
{{- else -}}
files/{{ index $parts 0 }}/{{ join "-" (rest $parts) }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Target language for Lingua detector
*/}}
{{- define "assistant.targetLanguage" -}}
{{- $v := include "assistant.variant" . -}}
{{- if or (eq $v "lemonade") (hasPrefix "en-" $v) -}}
ENGLISH
{{- else if hasPrefix "pt-" $v -}}
PORTUGUESE
{{- else -}}
SPANISH
{{- end -}}
{{- end -}}

{{/*
Namespace for the active variant
  lemonade     -> lemonade-stand-assistant (unchanged original)
  alternatives -> <variant>-stand-assistant (e.g. es-cafe-stand-assistant)
*/}}
{{- define "assistant.namespace" -}}
{{- if .Values.namespace.name -}}
{{- .Values.namespace.name -}}
{{- else -}}
{{- $v := include "assistant.variant" . -}}
{{- if eq $v "lemonade" -}}
lemonade-stand-assistant
{{- else -}}
{{- printf "%s-stand-assistant" $v -}}
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
