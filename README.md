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

# Example 1: Clinical trial data
set.seed(42)
trial_data <- data.frame(
  subject_id = paste0("S", 1:50),
  age = sample(20:80, 50, replace = TRUE),
  sex = sample(c("M", "F"), 50, replace = TRUE),
  treatment = sample(c("Drug A", "Placebo"), 50, replace = TRUE),
  response = sample(c("Yes", "No"), 50, replace = TRUE)
)

chat <- create_clinical_chat(trial_data)
# chat$chat("What is the response rate by treatment?")

# Example 2: Lab values
lab_data <- data.frame(
  patient_id = 1:40,
  age = sample(30:70, 40, replace = TRUE),
  diagnosis = sample(c("Diabetes", "Hypertension", "None"), 40, replace = TRUE),
  hba1c = round(rnorm(40, 7.0, 1.2), 1)
)

chat2 <- create_clinical_chat(lab_data)
# chat2$chat("How many patients have diabetes? What is their mean HbA1c?")
```

## Launch a Shiny App

```r
run_clinchat_app(trial_data, title = "Trial Data Chat")
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
