# clinChat

**Conversational interfaces for clinical data using Large Language Models in R.**

`clinChat` helps clinical researchers, biostatisticians, and data scientists explore structured clinical datasets through natural language chat interfaces. It is built on the modern R LLM stack (`ellmer` + `shinychat`) and prioritizes privacy: your data stays local; the model only sees tool results you explicitly allow.

## Features

- Privacy-aware chat with clinical data frames
- Pre-built tools for summarization, filtering, column description, and basic statistics
- Ready-to-launch Shiny chat applications
- Easy integration with `ellmer` providers (OpenAI, Anthropic, local models, etc.)
- Designed for clinical and pharmaceutical data review workflows

## Installation

```r
# Install dependencies first
install.packages(c("shiny", "ellmer", "shinychat", "dplyr"))

# Then install this package (once on CRAN or from GitHub)
# install.packages("clinChat")
# or
# remotes::install_github("shekharchalwadigrepo-hub/clinChat")
```

## Quick Start

```r
library(clinChat)

# Example clinical-style data
data <- data.frame(
  patient_id = 1:100,
  age = sample(18:90, 100, replace = TRUE),
  sex = sample(c("M", "F"), 100, replace = TRUE),
  diagnosis = sample(c("Hypertension", "Diabetes", "Healthy"), 100, replace = TRUE),
  systolic_bp = sample(110:180, 100, replace = TRUE)
)

# Create a chat object with clinical tools registered
chat <- create_clinical_chat(
  data = data,
  system_prompt = "You are a helpful clinical data analyst. Answer questions about the dataset accurately using the available tools. Never invent patient data."
)

# Chat (requires API key configured for your provider)
chat$chat("How many patients have diabetes? What is their average age?")
```

## Launch a Shiny App

```r
run_clinchat_app(data)
```

## Privacy Notes

- Raw patient-level data is never sent to the LLM by default.
- Tools return aggregated summaries, counts, or filtered results that you control.
- Prefer local models (via Ollama or similar) for maximum privacy.
- Always review tool outputs before relying on model responses in regulated environments.

## Development Status

This is an initial release designed to be CRAN-ready. Contributions and feedback are welcome.

## License

MIT
