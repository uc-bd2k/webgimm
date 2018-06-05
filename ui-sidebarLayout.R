# ui.R

shinyUI(fluidPage(
  # Application title
    titlePanel("Hello Shiny!"),

  # Sidebar with a slider input for the number of bins
    sidebarLayout(
        sidebarPanel(
            fileInput("inputFile", label = h3("File input"))
#            textOutput("clustResults")
        ),
        mainPanel(
#       textOutput("fileName"),
#       tableOutput("fileName"),
#       tableOutput("toCluster")
        textOutput("fileName"),
        dataTableOutput("toCluster"),
        textOutput("clustResults")
        )
    )
))     

