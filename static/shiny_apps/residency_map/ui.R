library(shiny)
library(leaflet)
library(RColorBrewer)
library(shiny)

shinyUI(
  bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  leafletOutput("map", width = "100%", height = "100%"),
  absolutePanel(top = 10, right = 10,
                selectInput("Primary.Specialty", "Specialty",
                            choices = c("Anesthesiology",
                                        "Child Neurology",
                                        "Dermatology",
                                        "Emergency Medicine",
                                        "Family Medicine",
                                        "General Surgery",
                                        "Internal Medicine",
                                        "Medicine-Pediatrics",
                                        "Medicine-Psychiatry",
                                        "Medicine‐Emergency Med",
                                        "Medicine‐Neurology",
                                        "Medicine‐Psychiatry",
                                        "Neurological Surgery",
                                        "Neurology",
                                        "Obstetrics‐Gynecology",
                                        "Ophthalmology",
                                        "Orthopaedic Surgery",
                                        "Otolaryngology",
                                        "Pathology",
                                        "Pediatrics",
                                        "Physical Medicine and Rehabilitation",
                                        "Plastic Surgery",
                                        "Psychiatry",
                                        "Psychiatry‐Family Med",
                                        "Radiation‐Oncology",
                                        "Radiology-Diagnostic",
                                        "Urology")))
    )
  )
