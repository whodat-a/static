library(shiny)
library(leaflet)
library(RColorBrewer)
library(maps)

capwords <- function(s, strict = FALSE) {
  cap <- function(s) paste(toupper(substring(s, 1, 1)),
                           {s <- substring(s, 2); if(strict) tolower(s) else s},
                           sep = "", collapse = " " )
  sapply(strsplit(s, split = " "), cap, USE.NAMES = !is.null(names(s)))
}

# mapStates = map("state", fill = TRUE)
# data("us.cities")
map.cities(us.cities)
# leaflet(mapStates) %>% addTiles() %>% setView(lng = -97.00, lat = 38.00, zoom = 4)

# import and clean data
alumni <- read.csv("TUSOM Residency Match List 2010-2015 - Sheet1.csv", stringsAsFactors = F, header = T)
# convert city to lowercase then capitalize it, then paste it together with the state
# we're doing this to match the alumni data to the us.cities data
alumni$city.state <- paste(capwords(tolower(alumni$City)), alumni$State)

# merge the data by the city.state column we just created and the name column in the us.cities data
alumni.map.data <- merge(alumni, us.cities, by.x = "city.state", by.y = "name")

shinyServer(function(input, output, session) {
    
    # Reactive expression for the data subsetted to what the user selected
    filteredData <- reactive({
      alumni.map.data[alumni.map.data$Primary.Specialty == input$Primary.Specialty,]
    })
    
    # sorted.data <- sort(unique(alumni.map.data$Primary.Specialty))
    # 
    # output$sorted.data <- renderUI({selectInput("sorted.data", "", 
    #                                             choices = sorted.data)})
    
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
    
  })