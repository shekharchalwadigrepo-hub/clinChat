# Example usage of clinChat

library(clinChat)

# Create example data
set.seed(42)
demo_data <- data.frame(
  patient_id = 1:200,
  age = round(rnorm(200, 55, 12)),
  sex = sample(c("M", "F"), 200, replace = TRUE),
  diagnosis = sample(c("Type 2 Diabetes", "Hypertension", "Both", "None"), 200, replace = TRUE),
  hba1c = round(rnorm(200, 7.2, 1.5), 1),
  systolic_bp = round(rnorm(200, 135, 18))
)

# Preview
head(demo_data)

# Create chat (uncomment after setting API key)
# chat <- create_clinical_chat(demo_data)
# chat$chat("How many patients have Type 2 Diabetes? What is their mean HbA1c?")

# Or launch the app
# run_clinchat_app(demo_data, title = "Demo Clinical Chat")
