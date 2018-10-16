# library(shinyIncubator)
library(shinyjs)

shinyServer(function(input, output) {
sessionID<-paste(gsub(":","_",gsub(" ","_",date())),trunc(10000000*runif(1)),sep="_")
print(sessionID)
#wd<-"/opt/raid10/genomics/Web/GenomicsPortals/ilincs/gimm"
wd<-"/mnt/raid/tmp"
wwd<-"http://eh3.uc.edu/genomics/GenomicsPortals/ilincs/gimm"
# wd<-"/mnt/raid/tmp/gimm"
# wwd<-"http://eh3.uc.edu/tmp/gimm"
setwd(wd)

values<-reactiveValues(gimmOut=NULL)

output$fileName<-renderText({
	if(is.null(input$inputFile)) return(NULL)
        as.character(input$inputFile[1,"datapath"])
})

inputDataTable<-reactive({
        if(input$example){
            inputData<-read.table(file="/opt/raid10/genomics/mario/r/shiny/DCE_Genes_GSE11121.txt", sep="\t", header=T, quote="", stringsAsFactors=F)
#             info(paste("Loaded dataset with ",dim(inputData)[1]," genes and ",dim(inputData)[2]-2," samples",sep=""))
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

# observe({
#       if(!is.null(inputDataTable())){
# #         enable("cluster")
#        	info(paste("Loaded dataset with ",dim(inputDataTable())[1]," genes and ",dim(inputDataTable())[2]-2," samples",sep=""))
#       }
# })

output$toCluster<-renderDataTable({
  print("blablah")
	inputDataTable()},
	options = list(pageLength = 5)
)

observe({
print(input$cluster)
      if(is.null(inputDataTable())){
        disable("cluster")
      }
})

output$junk<-renderText({print("blah")})
output$junkjunk<-renderTable({
  print("blahblahbalh")
})

observeEvent(input$cluster,
                                  {
print(101)
print(dim(inputDataTable()))
	if(is.null(inputDataTable())) return(NULL)
print(input$cluster)
print("About to run gimm")
#        if(input$cluster){
            library(gimmR)
print("running gimm")

            values$gimmOut<-runGimmNPosthoc(inputDataTable(),dataFile=sessionID,M=dim(inputDataTable())[2]-2, T=dim(inputDataTable())[1], nIter=50, nreplicates=1,   burnIn=20,verbose=F, contextSpecific = "y", nContexts = dim(inputDataTable())[2]-2, contextLengths = rep(1,dim(inputDataTable())[2]-2),estimate_contexts = "y",intFiles=F)
        
#         progress$inc(1/3, detail = "Creating TreeView Files")
            source("/opt/raid10/genomics/software/RPrograms/source/createJnlpFile.R")
            
            junk<-createJnlpFileGenomics(ilincs=F,fileName=paste(sessionID,".jnlp",sep=""),location=wd, webLocation=wwd, targetFilesLocation=wd, targetFilesName=paste(sessionID,".cdt",sep=""), targetWebLocation=wwd)
print(junk)
           system(paste("zip ",sessionID,".zip ",sessionID,".cdt ",sessionID,".gtr ",sessionID,".atr",sep=""))
           output$clustResults<-renderText({"***"})
#      }
})


#UNSTABLE CLUSTERING

# output$hiddenbutton <- renderText({
#   cluster<-cutree(gimmOut$hGClustData,k=input$numclust)
#   print(cluster)
#   })

output$treeviewLink <- renderUI({
      tags$a(href = paste(wwd,"/",sessionID,".jnlp",sep=""), "View results with FTreeView")
})

output$downloadLink <- renderUI({
      tags$a(href = paste(wwd,"/",sessionID,".zip",sep=""), "Download clustering results")
})

output$morpheus <- renderMorpheus({
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

# observeEvent(input$morpheusLink,
#              {
#                print("link")
#                print(input$morpheuslink)
#                showElement("hidden1")}, ignoreInit = TRUE)
# 
# observeEvent(input$morpheusLink,
#              {
#              hideElement("morpheusLink")}, ignoreInit = TRUE)

hideTab("tabset","morpheusTab")

hideTab("tabset", "clusterTab")

observeEvent(input$cluster, {
  showTab("tabset", "morpheusTab", select = TRUE)
})


# observeEvent(input$hiddenbutton,{
#   showTab("tabset", "clusterTab", select = TRUE)
# })
  
# observeEvent(input$cluster, {
#   showElement("hiddenbutton")}, ignoreInit = TRUE)
# })

})
