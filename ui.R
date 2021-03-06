library(shinyjs)
library(shinyBS)
library(DT)
library(morpheus)
library(shinycssloaders)
source("helpers.R")
shinyUI(fluidPage(style = "border-color:#848482",
                  useShinyjs(),
  # Application title
    navbarPage(strong(em("Webgimm Server",style = "color:white")), inverse = TRUE, position = "fixed-top"
               ),
           tags$head(tags$style(type="text/css", "
          ")),
  
    conditionalPanel(condition="$('html').hasClass('shiny-busy')",
                            tags$div("WORKING...",id="loadmessage")),
    fluidRow(column(12,
        h5(
            HTML("Cluster analysis of gene expression data using Context Specific Infinite Mixture Model "),
            a(href="http://eh3.uc.edu/gimm/dcim/",em("Freudenberg et al, BMC Bioinformatics 11:234. 2010"))
        ),
        br(),
        br()
    )),
    mainPanel(
      tabPanel(" ", fluidRow(
        column(2,
            h4("Open Data File")
        ),
        column(2,
            actionLink("example",label=h4("(Load example)"))
        )
    )),
    tabPanel(" ",
             fluidRow(
        
        column(4,
#            wellPanel(
                fileInput("inputFile", label = NULL),
                bsTooltip("inputFile", "Reading tab-delimited file with data to be clustered. Rows are genes and columns are samples. First two columns provide gene annotations and first row contains column names.", "top", options = list(container = "body")),
                withBusyIndicatorUI(actionButton("cluster",label="Run Cluster Analysis", class = "btn-primary", style = "background-color: #32CD32; border-color: #215E21")),
                bsTooltip("cluster", "Run the Gibbs sampler and construct hierarchical clustering of genes and samples based on the Gibbs sampler output as described in the reference paper", "top", options = list(container = "body")),
# conditionalPanel(condition="input.cluster%2==1",
                 conditionalPanel(condition="output.clustResults=='***'",
                                  br(),
                uiOutput("treeviewLink"),
                bsTooltip("treeviewLink", "Interactively browse clustering results using FTreeView Java application. You will need a recent version of Java installed and enabled.", "top", options = list(container = "body")),
                uiOutput("downloadLink"),
                bsTooltip("downloadLink", "Download zip archive of clustering results consisting of .cdt, .gtr and .atr files. The clustering can be viewed using FTreeView, TreeView, or similar applications. It can also be imported into R using ctc or CLEAN packages", "top", options = list(container = "body"))
		
#UNSTABLE CLUSTERING	
		
		            # numericInput("numclust", "Number of Clusters", value = 1),
		            # actionButton("hiddenbutton", "Show Clusters", style = "background-color: #D53412; border-color: #80210D", class = "btn-primary")
		            
                #            )
            
        )),
        column(8,
            tabsetPanel(id = "tabset",
              tabPanel("Data", 
                       br(),
                       withSpinner(dataTableOutput("toCluster"), color = getOption("spinner.color", default = "#000000"), size = getOption("spinner.size", default = 1.2))
              # textOutput("clustResults")
              ),
            tabPanel("Morpheus", value = "morpheusTab",
                        br(),
              print(strong("Morpheus Interface")),
                        br(),
              withSpinner(morpheusOutput("morpheus", width = 900, height = "600px"), color = getOption("spinner.color", default = "#000000"), size = getOption("spinner.size", default = 1.2))
            )
            
#UNSTABLE CLUSTERING
                
            # tabPanel("Clusters", value = "clusterTab",
            #          withSpinner(textOutput("hiddenbutton"), color = getOption("spinner.color", default = "#000000"), size = getOption("spinner.size", default = 1.2))
            )
          ),
textOutput("clustResults")

    ))
)))
