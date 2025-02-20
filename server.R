library(shinycssloaders)
library(shinyjs)

options(shiny.maxRequestSize = 30*1024^2)
if (!interactive()) sink(stderr(), type = "output")

shinyServer(function(input, output,session) {
  sessionID<-paste(gsub(":","_",gsub(" ","_",date())),trunc(10000000*runif(1)),sep="_")
  print(sessionID)
  cwd<-getwd()
  print(cwd)
# wd<-"/opt/raid10/genomics/Web/sccmap/webgimm/tmp/"
  wd<-paste0(cwd,"/tmp/")
  # wd<-"/Users/medvedm/restoredUCOneDrive/git/ucbd2k/webgimm/tmp/"
  wwd<-"http://www.ilincs.uc.edu/genomics/sccmap/webgimm/tmp"
  setwd(wd)

  values<-reactiveValues(gimmOut=NULL,runClustering=FALSE)
  inputDataTable<-NULL

  output$fileName<-renderText({
	  if(is.null(input$inputFile)) return(NULL)
    as.character(input$inputFile[1,"datapath"])
  })

  inputDataTable<-reactive({
    if(input$example){
      inputData<-read.table(file="DCE_Genes_GSE11121.txt", sep="\t", header=T, quote="", stringsAsFactors=F)
      print("data loaded")
      return(inputData)
    }
	  if(is.null(input$inputFile)) return(NULL)
	  inputData<-read.table(file=as.character(input$inputFile[1,"datapath"]), sep="\t", header=T, stringsAsFactors=F)
    return(inputData)
	})

  observe({
    if(!is.null(inputDataTable())){
      enable("cluster")
    }
  })


  observe({
    print(input$cluster)
    if(is.null(inputDataTable())){
      disable("cluster")
    }
  })

# output$junk<-renderText({print("blah")})
# output$junkjunk<-renderTable({
#   print("blahblahbalh")
# })


  observeEvent(input$cluster,{
    showTab("tabset", "morpheusTab", select = TRUE)
    if(is.null(inputDataTable())) return(NULL)
    library(gimmR)
    print("running gimm")
    showPageSpinner(
      {values$gimmOut<-runGimmNPosthoc(inputDataTable(),dataFile=sessionID,M=dim(inputDataTable())[2]-2, T=dim(inputDataTable())[1], nIter=200, nreplicates=1,   burnIn=20,verbose=F, contextSpecific = "y", nContexts = dim(inputDataTable())[2]-2, contextLengths = rep(1,dim(inputDataTable())[2]-2),estimate_contexts = "y",intFiles=F)},
      caption="Running Gibbs Sampler")

    system(paste("zip ",sessionID,".zip ",sessionID,".cdt ",sessionID,".gtr ",sessionID,".atr",sep=""))
    output$clustResults<-renderText({"***"})
    unlink(c(paste0(sessionID,".gtr"), paste0(sessionID,".atr"), paste0(sessionID,".zm"),paste0(sessionID,".wc"),paste0(sessionID,".zm2"),paste0(sessionID,".cdt"),paste0(sessionID,".pos")), recursive = F)

    library(morpheus)
    output$morpheus <- morpheus::renderMorpheus({
      test<-inputDataTable()
      rownames(test)<-test[,2]
      morpheus(test[,-(1:2)],
               # distfun = function(x) {as.dist(1 - cor(t(x), use = "pairwise.complete.obs"))},
               Rowv = as.dendrogram(values$gimmOut$hGClustData),
               Colv = T,
               dendrogram = "both",
               rowAnnotation = test[,1:2],
               colorScheme = list(scalingMode = "fixed", values = list(-2,0,2),
                                  colors = list("blue", "black", "yellow"))
      )
    }, env = environment(), quoted = F)

    showTab("tabset", "morpheusTab", select = TRUE)
  })

  output$downloadLink <- renderUI({
    tags$a(href = paste(wwd,"/",sessionID,".zip",sep=""), "Download clustering results")
  })

  hideTab("tabset","Data")
  hideTab("tabset","morpheusTab")

  observe({
    if(!is.null(inputDataTable())){
      output$toCluster <- DT::renderDataTable({
        DT::datatable(inputDataTable(), options = list(scrollX = T))}
        , server = F)
      showTab("tabset", "Data", select = TRUE)
    }
  })

  # onSessionEnded(function(){unlink(c(paste0(sessionID,".gtr"), paste0(sessionID,".atr"), paste0(sessionID,".zm"),paste0(sessionID,".wc"),paste0(sessionID,".zm2"),paste0(sessionID,".cdt"),paste0(sessionID,".pos")), recursive = F)})

})
