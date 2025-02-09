library(shinyjs)
library(shinyBS)
library(DT)
library(morpheus)
library(shinycssloaders)
# source("/opt/raid10/genomics/Web/sccmap/webgimm/helpers.R")

print("UI libraries loaded")
shinyUI(fluidPage(style = "border-color:#848482",
  useShinyjs(),
  # Application title
  navbarPage(strong(em("Webgimm Server",style = "color:white")), inverse = TRUE, position = "fixed-top"),
           tags$head(tags$style(type="text/css", "")),

  # conditionalPanel(condition="$('html').hasClass('shiny-busy')",
                   # tags$div("WORKING...",id="loadmessage")),
  br(),br(),br(),

  fluidRow(column(12,
    h5(
      HTML("Cluster analysis of gene expression data using Context Specific Infinite Mixture Model "),
      a(href="http://eh3.uc.edu/gimm/dcim/",em("Freudenberg et al, BMC Bioinformatics 11:234. 2010"))
    ),
    br(),
    br()
  )),

  mainPanel(
    tabPanel("readExampleData", fluidRow(
      column(3,
          h4("Open Data File")
      ),
      column(3,
          actionLink("example",label=h4("(Load example)"))
      )
    )),
    tabPanel("readAndAnalyze", fluidRow(
     column(4,
       fileInput("inputFile", label = NULL),
       bsTooltip("inputFile", "Reading tab-delimited file with data to be clustered. Rows are genes and columns are samples. First two columns provide gene annotations and first row contains column names.", "top", options = list(container = "body")),

       actionButton("cluster",label="Run Cluster Analysis", class = "btn-primary", style = "background-color: #32CD32; border-color: #215E21"),
       bsTooltip("cluster", "Run the Gibbs sampler and construct hierarchical clustering of genes and samples based on the Gibbs sampler output as described in the reference paper", "top", options = list(container = "body")),
       conditionalPanel(condition="output.clustResults=='***'",
          br(),
          uiOutput("downloadLink"),
          bsTooltip("downloadLink", "Download zip archive of clustering results consisting of .cdt, .gtr and .atr files. The clustering can be viewed using FTreeView, TreeView, or similar applications. It can also be imported into R using ctc or CLEAN packages", "top", options = list(container = "body"))

  )),
    column(8,
       tabsetPanel(id = "tabset",
        tabPanel("Data",
          br(),
          withSpinner(dataTableOutput("toCluster"), color = getOption("spinner.color", default = "#000000"), size = getOption("spinner.size", default = 1.2))
          ),
        tabPanel("Morpheus", value = "morpheusTab",
          br(),
          print(strong("Clustering Results")),
          br(),
          print("Genes are clustered using the DCIM model"),
          br(),
          print("Samples are clustered using Pearsons correlations"),
          br(),
          withSpinner(morpheusOutput("morpheus", width = 900, height = "600px"), color = getOption("spinner.color", default = "#000000"), size = getOption("spinner.size", default = 1.2))
          # morpheusOutput("morpheus", width = 900, height = "600px")
        )
    )),
  textOutput("clustResults")

    ))
)))
