###The busy bar is not working for some reason. Don't know why
# loadingBar <- tags$div(class="progress progress-striped active",
#                        tags$div(class="bar", style="width: 100%;"))
# # Code for loading message
# loadingMsg <- tags$div(class="modal", tabindex="-1", role="dialog", 
#                        "aria-labelledby"="myModalLabel", "aria-hidden"="true",
#                        tags$div(class="modal-header",
#                                 tags$h3(id="myModalHeader", "Loading...")),
#                        tags$div(class="modal-footer",
#                                 loadingBar))
# # The conditional panel to show when shiny is busy
# loadingPanel <- conditionalPanel(paste("input.cluster > 0 &&", 
#                                        "$('html').hasClass('shiny-busy')"),
#                                  loadingMsg)
# ui.R

# library(shinyIncubator)
library(shinyjs)
library(shinyBS)
shinyUI(fluidPage(
  # Application title
    titlePanel("WebGimm Server"),
           tags$head(tags$style(type="text/css", "
             #loadmessage {
               position: fixed;
               top: 50%;
               left: 20%;
               width: 80%;
               padding: 5px 0px 5px 0px;
               text-align: center;
               font-weight: bold;
               font-size: 300%;
               color: #000000;
               background-color: #0080FF;
               z-index: 105;
             }
          ")),
    conditionalPanel(condition="$('html').hasClass('shiny-busy')",
                            tags$div("Working...",id="loadmessage")),
#     conditionalPanel(condition="$('html').hasClass('shiny-busy')",loadingMsg), 
    fluidRow(column(12,
        h5(
            HTML("Cluster analysis of gene expression data using Context Specific Infinite Mixture Model "),
            a(href="http://eh3.uc.edu/gimm/dcim/",em("Freudenberg et al, BMC Bioinformatics 11:234. 2010"))
        ),
        br(),
        br()
    )),
    fluidRow(
        column(2,
            h4("Open data file")
        ),
        column(2,
            actionLink("example",label=h4("(Load example)"))
        )
    ),
    fluidRow(
        useShinyjs(),
        column(4,
#            wellPanel(
                fileInput("inputFile", label = NULL),
                bsTooltip("inputFile", "Reading tab-delimited file with data to be clustered. Rows are genes and columns are samples. First two columns provide gene annotations and first row contains column names.", "top", options = list(container = "body")),
                actionButton("cluster",label="Run Cluster Analysis"),
                bsTooltip("cluster", "Run the Gibbs sampler and construct hierarchical clustering of genes and samples based on the Gibbs sampler output as described in the reference paper", "top", options = list(container = "body")),
#                 actionButton("treeview",label="View Results"),
#                 bsTooltip("treeview", "Interactively browse clustering results using FTreeView Java application. You will need a recent version of Java installed and enabled.", "top", options = list(container = "body")),
#                 actionButton("download",label="Download Results"),
#                 bsTooltip("download", "Download zip archive of clustering results consisting of .cdt, .gtr and .atr files. The clustering can be viewed using FTreeView, TreeView, or similar applications. It can also be imported into R using ctc or CLEAN packages", "top", options = list(container = "body")),
#         	verbatimTextOutput("cluster")
	      conditionalPanel(condition="output.clustResults=='Finished'",
		br(),
                uiOutput("treeviewLink"),
                bsTooltip("treeviewLink", "Interactively browse clustering results using FTreeView Java application. You will need a recent version of Java installed and enabled.", "top", options = list(container = "body")),
                uiOutput("downloadLink"),
                bsTooltip("downloadLink", "Download zip archive of clustering results consisting of .cdt, .gtr and .atr files. The clustering can be viewed using FTreeView, TreeView, or similar applications. It can also be imported into R using ctc or CLEAN packages", "top", options = list(container = "body"))
		)
                #            )
            
        ),
        column(8,
#           tableOutput("toCluster")
#            textOutput("fileName"),
            dataTableOutput("toCluster"),
              textOutput("clustResults")
        )
        
    )
))     

