# Guardrail the Lemonade Stand Assistant

Deploy an AI-powered customer service assistant with built-in safety guardrails to ensure family-friendly, compliant interactions for your business. With a dashboard for metrics and a chat UI, abuse the system and see how it responds! 

Built by Anneli Sara Banderby and Cansu Kavili-Örnek. 

## Table of Contents

- [Detailed description](#detailed-description)
  - [Architecture diagrams](#architecture-diagrams)
  - [See it in action](#see-it-in-action)
  - [Monitoring dashboards](#monitoring-dashboards)
- [Demo variants](#demo-variants)
- [Requirements](#requirements)
  - [Minimum hardware requirements](#minimum-hardware-requirements)
  - [Minimum software requirements](#minimum-software-requirements)
- [Deploy](#deploy)
  - [Prerequisites](#prerequisites)
  - [Deployment](#deployment)
  - [Configuration options](#configuration-options)
  - [Validating the deployment](#validating-the-deployment)
  - [Delete](#delete)
- [Technical details](#technical-details)
  - [Architecture](#architecture)
  - [Models](#models)
  - [Deployment Configuration](#deployment-configuration)
- [Reference](#reference)
- [Tags](#tags)


## Detailed description

Imagine we run a successful lemonade stand and want to deploy a customer service agent so our customers can learn more about our products. We'll want to make sure all conversations with the agent are family friendly, and that it does not promote our rival fruit juice vendors.

This demo showcases how to deploy an AI-powered customer service assistant with multiple guardrails to ensure safe, compliant, and on-brand interactions. The solution uses [Llama 3.2](https://huggingface.co/RedHatAI/Llama-3.2-3B-Instruct-FP8-dynamic) as the default language model (or your own model endpoint), protected by three detector models that monitor for harmful content, prompt injection attacks, and language compliance.

**In this demo, we are following these principles:** 

1. The LLM is untrusted. All its output must be validated. 
2. The user is untrusted. All the input must be validated.
3. Triggering of specific detectors is monitored and visualized. (Alerts are out of scope but could be done)

The Lemonade Stand Assistant provides an interactive customer service experience for a fictional lemonade stand business. Customers can ask questions about products, ingredients, pricing, and more through a conversational interface.

https://github.com/user-attachments/assets/998dd37d-6130-4971-b8a2-d4ded8c40a27

To ensure safe and appropriate interactions, the system employs multiple AI guardrails:
- **[IBM HAP Detector (Granite Guardian)](https://huggingface.co/ibm-granite/granite-guardian-hap-125m)**: Monitors conversations for hate, abuse, and profanity
- **[Prompt Injection Detector (DeBERTa v3)](https://huggingface.co/protectai/deberta-v3-base-prompt-injection-v2)**: Identifies and blocks attempts to manipulate the AI assistant
- **[Lingua Language Detector](https://github.com/pemistahl/lingua)**: Ensures inputs and responses match the variant language (English, Spanish, or Portuguese)

Furthermore, there is a:
- **Regex Detector**: Blocks specific text without the use of models. In our case, off-topic competitors (other fruits or beverages, depending on the variant).

The guardrails orchestrator coordinates these detectors to evaluate inputs and outputs before presenting responses to users.

## Demo variants

The **original** demo is the English lemonade stand (`lemonade-stand-app/`). Localized alternatives live under [`alternatives/`](./alternatives/), grouped by language:

| Variant | Language | Theme | Namespace / release | App / Route | Values file |
|---------|----------|-------|---------------------|-------------|-------------|
| `lemonade` (**original**) | English | Lemons | `lemonade-stand-assistant` | `lemonade-stand` | `chart/values-lemonade.yaml` |
| `en-coffee` | English | Coffee | `en-coffee-stand-assistant` | `en-coffee-stand` | `chart/values-en-coffee.yaml` |
| `es-cafe` | Spanish | Café | `es-cafe-stand-assistant` | `es-cafe-stand` | `chart/values-es-cafe.yaml` |
| `es-mate` | Spanish | Mate (Uruguay) | `es-mate-stand-assistant` | `es-mate-stand` | `chart/values-es-mate.yaml` |
| `es-piscola` | Spanish | Piscola (Chile) | `es-piscola-stand-assistant` | `es-piscola-stand` | `chart/values-es-piscola.yaml` |
| `es-chicha` | Spanish | Chicha morada (Perú) | `es-chicha-stand-assistant` | `es-chicha-stand` | `chart/values-es-chicha.yaml` |
| `es-ceviche` | Spanish | Ceviche (Perú) | `es-ceviche-stand-assistant` | `es-ceviche-stand` | `chart/values-es-ceviche.yaml` |
| `es-tacos` | Spanish | Tacos (México) | `es-tacos-stand-assistant` | `es-tacos-stand` | `chart/values-es-tacos.yaml` |
| `es-limonada` | Spanish | Limonada | `es-limonada-stand-assistant` | `es-limonada-stand` | `chart/values-es-limonada.yaml` |
| `es-tequila` | Spanish | Tequila (México) | `es-tequila-stand-assistant` | `es-tequila-stand` | `chart/values-es-tequila.yaml` |
| `pt-cafe` | Portuguese | Café | `pt-cafe-stand-assistant` | `pt-cafe-stand` | `chart/values-pt-cafe.yaml` |
| `pt-cachaca` | Portuguese | Cachaça | `pt-cachaca-stand-assistant` | `pt-cachaca-stand` | `chart/values-pt-cachaca.yaml` |
| `pt-limonada` | Portuguese | Limonada | `pt-limonada-stand-assistant` | `pt-limonada-stand` | `chart/values-pt-limonada.yaml` |
| `pt-caipirinha` | Portuguese | Caipirinha (Brasil) | `pt-caipirinha-stand-assistant` | `pt-caipirinha-stand` | `chart/values-pt-caipirinha.yaml` |

The original keeps historical names. Alternatives follow the same pattern: `<variant>-stand` (app/route) and `<variant>-stand-assistant` (namespace/release). OpenShift route hosts look like `es-cafe-stand-es-cafe-stand-assistant.apps...`.

```
lemonade-stand-app/          # original English lemonade sources
alternatives/
  en/coffee/
  es/cafe/
  es/mate/
  es/piscola/
  es/chicha/
  es/ceviche/
  es/tacos/
  es/limonada/
  es/tequila/
  pt/cafe/
  pt/cachaca/
  pt/limonada/
  pt/caipirinha/
chart/files/                 # Helm-mounted assets
  lemonade/                  # original
  en/coffee/
  es/...
  pt/cafe/
  pt/cachaca/
  pt/limonada/
  pt/caipirinha/
```
See [`alternatives/README.md`](./alternatives/README.md) for editing tips.

### Sharing models across variants

LLM, HAP, prompt-injection and MinIO live **only** in `lemonade-stand-assistant`. Alternative values files enable `models.shared` and point at that namespace (Lingua stays local per language).

Install the original lemonade stack first (owns the models), then any number of alternatives:

```bash
# 1) Original — app + models (--create-namespace creates the project)
helm upgrade --install lemonade-stand-assistant ./chart \
  --create-namespace -n lemonade-stand-assistant \
  -f chart/values-lemonade.yaml

# Wait until models are Ready
oc get inferenceservice -n lemonade-stand-assistant -w

# 2) Alternatives — share models from lemonade-stand-assistant
helm upgrade --install es-cafe-stand-assistant ./chart \
  --create-namespace -n es-cafe-stand-assistant \
  -f chart/values-es-cafe.yaml

helm upgrade --install pt-cafe-stand-assistant ./chart \
  --create-namespace -n pt-cafe-stand-assistant \
  -f chart/values-pt-cafe.yaml
```

- Orchestrator DNS example: `llama-32-predictor.lemonade-stand-assistant.svc.cluster.local`
- Full isolated stack for an alternative (own GPU models): add `--set models.shared.enabled=false`
- Uninstalling an alternative does **not** remove `lemonade-stand-assistant` or the shared models
- Installing an alternative **fails** if the lemonade InferenceServices are missing (`models.shared.validate`)

**Where are the models?** Always in `lemonade-stand-assistant` (unless you use `--set models.shared.enabled=false`):

```bash
oc get inferenceservice -n lemonade-stand-assistant
# NAME                            URL   READY   PREV   LATEST   PREVROLLEDOUTREVISION   LATESTREADYREVISION   AGE
# llama-32                        ...   True
# guardrails-detector-ibm-hap     ...
# prompt-injection-detector       ...
```

### Grafana vs Shiny monitoring

The default deploy uses the **Shiny** dashboard. An older/alternate packaging that uses **Grafana** lives in [`grafana-version/`](./grafana-version/) (Grafana Operator + Prometheus dashboards). That folder is independent of the language/theme variants above.

### Architecture Diagrams

![architecture.png](./docs/images/architecture.png)

### See it in action

**[▶️ View Interactive Demo](https://interact.redhat.com/share/ccMmWuFhRNPc9ppjTAz4)**


### Monitoring Dashboard

The solution includes an R Shiny monitoring dashboard for visualizing guardrail detections in real-time, including detections by detector type, total requests, input/output blocks, and approved requests.

**R Shiny Dashboard**

![shiny-dashboard.png](./docs/images/shiny-dashboard.png)

The Shiny dashboard is deployed automatically with the lemonade-stand-assistant by default.

The dashboard automatically fetches metrics from the lemonade-stand app every second and displays:
- Total requests counter
- Input blocked counter
- Output blocked counter  
- Approved requests counter
- Detection breakdown by guardrail type (with progress bars)

To access the dashboard after deployment:

```bash
# Get the dashboard URL
echo https://$(oc get route shiny-dashboard -n lemonade-stand-assistant --template='{{.spec.host}}')
```

## Requirements

### Minimum hardware requirements

**Llama 3.2 3B Instruct (Main LLM — only when deploying the default model):**
- CPU: 1 vCPU (request) / 4 vCPU (limit)
- Memory: 8 GiB (request) / 20 GiB (limit)
- GPU: 1 NVIDIA GPU (e.g., A10, A100, L40S, T4, or similar)

**IBM HAP Detector (Granite Guardian HAP 125M):**
- CPU: 1 vCPU (request) / 2 vCPU (limit)
- Memory: 4 GiB (request) / 8 GiB (limit)

**Prompt Injection Detector (DeBERTa v3 Base):**
- CPU: 4 vCPU (request) / 8 vCPU (limit)
- Memory: 16 GiB (request) / 24 GiB (limit)

**Lingua Language Detector:**
- CPU: 1 vCPU (request) / 2 vCPU (limit)
- Memory: 2 GiB (request) / 3 GiB (limit)

**Total Resource Requirements:**
- CPU: 7 vCPU (request) / 16 vCPU (limit)
- Memory: 30 GiB (request) / 51 GiB (limit)
- GPU: 1 NVIDIA GPU (only when deploying the default model)

> **Note**: If you bring your own model endpoint, the LLM resources and GPU are not required. The detector models are configured to run on CPU by default. If you have additional GPU resources available and want to improve detector performance, you can enable GPU acceleration for the detectors. See the [Configuration Options](#configuration-options) section for details on customizing GPU usage.

### Minimum software requirements

- Red Hat OpenShift Container Platform
- Red Hat OpenShift AI

## Deploy

### Prerequisites

Before deploying, ensure you have:
- Access to a Red Hat OpenShift cluster with OpenShift AI installed and TrustyAI enabled
- Cluster admin privileges to create the guardrails orchestrator resources
- `oc` CLI tool installed and configured
- `helm` CLI tool installed
- Sufficient resources available in your cluster

### Deployment

1. Clone the repository:
```bash
git clone https://github.com/rh-ai-quickstart/lemonade-stand-assistant.git
cd lemonade-stand-assistant
```

2. Install with Helm (`--create-namespace` creates the project if needed).

**Original lemonade** (owns LLM + detectors + MinIO):

```bash
helm upgrade --install lemonade-stand-assistant ./chart \
  --create-namespace -n lemonade-stand-assistant \
  -f chart/values-lemonade.yaml
```

**Alternatives** (install lemonade first and wait until InferenceServices are Ready):

```bash
oc get inferenceservice -n lemonade-stand-assistant

helm upgrade --install es-cafe-stand-assistant ./chart \
  --create-namespace -n es-cafe-stand-assistant -f chart/values-es-cafe.yaml

helm upgrade --install en-coffee-stand-assistant ./chart \
  --create-namespace -n en-coffee-stand-assistant -f chart/values-en-coffee.yaml

helm upgrade --install es-mate-stand-assistant ./chart \
  --create-namespace -n es-mate-stand-assistant -f chart/values-es-mate.yaml

helm upgrade --install es-piscola-stand-assistant ./chart \
  --create-namespace -n es-piscola-stand-assistant -f chart/values-es-piscola.yaml

helm upgrade --install es-chicha-stand-assistant ./chart \
  --create-namespace -n es-chicha-stand-assistant -f chart/values-es-chicha.yaml

helm upgrade --install es-ceviche-stand-assistant ./chart \
  --create-namespace -n es-ceviche-stand-assistant -f chart/values-es-ceviche.yaml

helm upgrade --install es-tacos-stand-assistant ./chart \
  --create-namespace -n es-tacos-stand-assistant -f chart/values-es-tacos.yaml

helm upgrade --install es-limonada-stand-assistant ./chart \
  --create-namespace -n es-limonada-stand-assistant -f chart/values-es-limonada.yaml

helm upgrade --install es-tequila-stand-assistant ./chart \
  --create-namespace -n es-tequila-stand-assistant -f chart/values-es-tequila.yaml

helm upgrade --install pt-cafe-stand-assistant ./chart \
  --create-namespace -n pt-cafe-stand-assistant -f chart/values-pt-cafe.yaml

helm upgrade --install pt-limonada-stand-assistant ./chart \
  --create-namespace -n pt-limonada-stand-assistant -f chart/values-pt-limonada.yaml

helm upgrade --install pt-caipirinha-stand-assistant ./chart \
  --create-namespace -n pt-caipirinha-stand-assistant -f chart/values-pt-caipirinha.yaml

helm upgrade --install pt-cachaca-stand-assistant ./chart \
  --create-namespace -n pt-cachaca-stand-assistant -f chart/values-pt-cachaca.yaml
```

**Option A: Use your own model (MaaS - Model as a Service)**

If you have an existing model endpoint, provide the model name, endpoint, port, and API key:
```bash
helm upgrade --install lemonade-stand-assistant ./chart --namespace ${PROJECT} \
  -f chart/values-lemonade.yaml \
  --set model.name=YOUR_MODEL_NAME \
  --set model.endpoint=YOUR_ENDPOINT \
  --set model.port=443 \
  --set model.api_key=YOUR_API_KEY
```

> **Note**: The `model.endpoint` should be the hostname only, without `https://` prefix or trailing `/`.

**Option B: Deploy with the default in-cluster model**

Omit `model.*` overrides; the chart deploys Llama 3.2 3B Instruct in `lemonade-stand-assistant`.

> **Note**: Option B requires a GPU available in your cluster for the LLM deployment. See [Minimum hardware requirements](#minimum-hardware-requirements) for details.

### Configuration Options

The deployment can be customized through the `values.yaml` file. Each detector can be configured to run on GPU or CPU depending on your available resources.

#### GPU Configuration

By default, only the LLM uses GPU acceleration. All detector models run on CPU.

Each detector supports the following configuration options:

- `useGpu`: Enable GPU acceleration for the detector (default: `false`)
- `resources`: CPU and memory resource requests and limits

**Example: Enable GPU for HAP detector (requires additional GPU)**
```bash
helm upgrade --install lemonade-stand-assistant ./chart --namespace ${PROJECT} \
  -f chart/values-lemonade.yaml \
  --set detectors.hap.useGpu=true
```

**Example: Enable GPU for all configurable detectors (requires 3 total GPUs)**
```bash
helm upgrade --install lemonade-stand-assistant ./chart --namespace ${PROJECT} \
  -f chart/values-lemonade.yaml \
  --set detectors.hap.useGpu=true \
  --set detectors.promptInjection.useGpu=true
```

**Example: Custom resource allocation for HAP detector**
```bash
helm upgrade --install lemonade-stand-assistant ./chart --namespace ${PROJECT} \
  -f chart/values-lemonade.yaml \
  --set detectors.hap.resources.requests.memory=2Gi \
  --set detectors.hap.resources.limits.memory=4Gi
```

### Validating the deployment

Once deployed, access the Lemonade Stand Assistant UI. You can find the route with:

```bash
echo https://$(oc get route/lemonade-stand -n ${PROJECT} --template='{{.spec.host}}')
```

Open the URL in your browser and start asking questions about lemonade and other fruits!

### Delete

```bash
# Original
helm uninstall lemonade-stand-assistant --namespace lemonade-stand-assistant
oc delete project lemonade-stand-assistant

# Alternative example
helm uninstall es-cafe-stand-assistant --namespace es-cafe-stand-assistant
oc delete project es-cafe-stand-assistant
```

## Technical details

### Architecture

The Lemonade Stand Assistant consists of the following components:

**Inference Services:**
- **[Llama 3.2 3B Instruct](https://huggingface.co/RedHatAI/Llama-3.2-3B-Instruct-FP8-dynamic)**: Main language model for generating responses
- **[IBM HAP Detector (Granite Guardian HAP 125M)](https://huggingface.co/ibm-granite/granite-guardian-hap-125m)**: Detects hate, abuse, and profanity
- **[Prompt Injection Detector (DeBERTa v3 Base)](https://huggingface.co/protectai/deberta-v3-base-prompt-injection-v2)**: Identifies prompt injection attempts
- **[Lingua Language Detector](https://github.com/pemistahl/lingua)**: Validates language compliance (English only)

**Orchestration:**
- **Guardrails Orchestrator**: Coordinates detector models using FMS Orchestr8
- **Lemonade Stand App**: FastAPI-based web application providing the user interface for customer interactions

### Models

| Component | Model | Size | Purpose |
|-----------|-------|------|---------|
| Main LLM | Llama 3.2 3B Instruct | 3B parameters | Conversational AI |
| HAP Detection | Granite Guardian HAP | 125M parameters | Content safety |
| Prompt Injection Guard | DeBERTa v3 Base | ~184M parameters | Security |
| Language Detection | Lingua | Rule-based | Language validation |

### Deployment Configuration

Models are deployed on OpenShift AI using:
- vLLM runtime for the main LLM (KServe InferenceService with optimized inference)
- Guardrails Detector runtime for HAP and Prompt Injection detectors (KServe InferenceServices)
- Standard Kubernetes Deployment for Lingua language detector

## Reference

This quickstart is based on the demo by the TrustyAI team. For more information and to contribute:

- [TrustyAI Lemonade Stand Demo](https://github.com/trustyai-explainability/trustyai-llm-demo/tree/lemonade-stand) - Original demo implementation
- [TrustyAI Community](https://github.com/trustyai-explainability) - Contribute to the TrustyAI explainability project

## Tags

* **Industry:** Retail 
* **Product:** OpenShift AI, Trusty AI 
* **Use case:** AI safety, content moderation
* **Contributor org:** Red Hat
