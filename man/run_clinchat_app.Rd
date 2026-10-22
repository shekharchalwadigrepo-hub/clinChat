\name{run_clinchat_app}
\alias{run_clinchat_app}
\title{Launch a Shiny chat application for clinical data}
\usage{
run_clinchat_app(
  data,
  system_prompt = NULL,
  provider = NULL,
  title = "Clinical Data Chat",
  ...
)
}
\arguments{
\item{data}{A data.frame of clinical data.}

\item{system_prompt}{Optional custom system prompt.}

\item{provider}{Provider string for ellmer (e.g. "openai/gpt-4o-mini").}

\item{title}{Title shown in the app.}

\item{...}{Additional arguments passed to shiny::runApp().}
}
\value{
Invisibly returns the Shiny app object. Called for its side effect
of launching the app.
}
\description{
Starts an interactive Shiny app that lets users chat with a clinical dataset
using a large language model. Uses shinychat for the interface and ellmer
for the model backend.
}
\examples{
\dontrun{
data <- iris
run_clinchat_app(data, title = "Iris Explorer")
}
}
