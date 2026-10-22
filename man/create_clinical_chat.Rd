\name{create_clinical_chat}
\alias{create_clinical_chat}
\title{Create a clinical data chat object}
\usage{
create_clinical_chat(data, system_prompt = NULL, provider = NULL, ...)
}
\arguments{
\item{data}{A data.frame containing clinical data.}

\item{system_prompt}{Character. System prompt for the model. Defaults to a
clinical analyst persona that emphasizes accuracy and privacy.}

\item{provider}{Character or NULL. Provider string for ellmer::chat(),
e.g. "openai/gpt-4o-mini". If NULL, uses the default from ellmer.}

\item{...}{Additional arguments passed to ellmer::chat().}
}
\value{
An ellmer Chat object with clinical tools registered.
}
\description{
Creates an ellmer::Chat object pre-configured with tools for exploring
a clinical dataset. Data remains local; only tool results are shared with
the model.
}
\examples{
\dontrun{
data <- data.frame(
  patient_id = 1:50,
  age = sample(30:80, 50, replace = TRUE),
  outcome = sample(c("responder", "non-responder"), 50, replace = TRUE)
)
chat <- create_clinical_chat(data)
chat$chat("Summarize the age distribution")
}
}
