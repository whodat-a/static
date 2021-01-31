library(shiny)
library(leaflet)
library(RColorBrewer)
library(maps)

ui <- bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  leafletOutput("map", width = "100%", height = "100%"),
  absolutePanel(top = 10, right = 10,
                selectInput("Primary.Specialty", "Specialty",
                            sort(unique(alumni.map.data$Primary.Specialty))
                )
  )
)

server <- function(input, output, session) {
  
  # Reactive expression for the data subsetted to what the user selected
  filteredData <- reactive({
    alumni.map.data[alumni.map.data$Primary.Specialty == input$Primary.Specialty,]
  })
  
  output$map <- renderLeaflet({
    # Use leaflet() here, and only include aspects of the map that
    # won't need to change dynamically (at least, not unless the
    # entire map is being torn down and recreated).
    leaflet(alumni.map.data) %>% addTiles() %>%
      fitBounds(~min(long), ~min(lat), ~max(long), ~max(lat))
  })
  
  # Incremental changes to the map (in this case, replacing the
  # circles when a new color is chosen) should be performed in
  # an observer. Each independent set of things that can change
  # should be managed in its own observer.
  observe({
    
    leafletProxy("map", data = filteredData()) %>%
      clearMarkers() %>% clearMarkerClusters() %>%
      addCircleMarkers(
        popup = ~as.character(paste(sep = "<br/>",
                                    paste0('<a href = ', #begin link format to search google
                                           "https://www.google.com/#q=",
                                           paste(First.Name,
                                                 Last.Name, "Tulane", sep = "+"), #search elements
                                           ">",
                                           paste(First.Name, Last.Name, sep = " "),
                                           '</a>'),  # end link format to search google
                                    paste("Class of", Class.Year, sep = " "),Program, 
                                    Primary.Specialty)),
        clusterOptions = markerClusterOptions()
      )
  })
}

shinyApp(ui, server)
