# library(shinyIncubator)

shinyServer(function(input, output) {
sessionID<-paste(gsub(":","_",gsub(" ","_",date())),trunc(10000000*runif(1)),sep="_")
print(sessionID)
# wd<-"/opt/raid10/genomics/Web/GenomicsPortals/ilincs/gimm"
# wwd<-"http://eh3.uc.edu/genomics/GenomicsPortals/ilincs/gimm"
wd<-"/mnt/raid/tmp/gimm"
wwd<-"http://eh3.uc.edu/tmp/gimm"
setwd(wd)

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

output$toCluster<-renderDataTable(
# 	{
	inputDataTable(),
	options = list(pageLength = 5)
# output$clustButton<-renderUI({
#  	if(is.null(input$inputFile)) return(NULL)
#  	actionButton("cluster",label="Cluster")
#  #	p("Current Value")
#  #	verbatimTextOutput("cluster")
# }
)
observe({
print(input$cluster)
      if(is.null(inputDataTable())){
        disable("cluster")
#         disable("treeview")
#         disable("download")
      }
})
       
# observe({
#       if(input$treeview) browseURL(paste(wwd,"/",sessionID,".jnlp",sep=""), browser="konqueror")
# })
#        
       
output$clustResults<-renderText({
# finishesClustering<-reactive({
print(1)
print(dim(inputDataTable()))
# 	if(is.null(input$inputFile)) return(NULL)
	if(is.null(inputDataTable())) return(NULL)
print(input$cluster)
        if(input$cluster){
            library(gimmR)
#         progress <- shiny::Progress$new()
# Make sure it closes when we exit this reactive, even if there's an error
#         on.exit(progress$close())
#         progress$set(message = "Analysis in Progress", detail="Reading Data", value = 0)
#             setwd("/opt/raid10/genomics/Web/GenomicsPortals/ilincs/gimm")
print("running gimm")
#print(inputDataTable())
#         progress$inc(1/3, detail = "Cluster Analysis")

            gimmOut<-runGimmNPosthoc(inputDataTable(),dataFile=sessionID,M=dim(inputDataTable())[2]-2, T=dim(inputDataTable())[1], nIter=50, nreplicates=1,   burnIn=20,verbose=F, contextSpecific = "y", nContexts = dim(inputDataTable())[2]-2, contextLengths = rep(1,dim(inputDataTable())[2]-2),estimate_contexts = "y",intFiles=F) 
        
#         progress$inc(1/3, detail = "Creating TreeView Files")
            source("/opt/raid10/genomics/software/RPrograms/source/createJnlpFile.R")
            
            junk<-createJnlpFileGenomics(ilincs=F,fileName=paste(sessionID,".jnlp",sep=""),location=wd, webLocation=wwd, targetFilesLocation=wd, targetFilesName=paste(sessionID,".cdt",sep=""), targetWebLocation=wwd)
print(junk)
           system(paste("zip ",sessionID,".zip ",sessionID,".cdt ",sessionID,".gtr ",sessionID,".atr",sep=""))
#       progress$inc(1/3, detail = "Done")
 
#             enable("treeview")
#             enable("download")
#             paste(names(gimmOut),sep="separator")
 	  "Finished"
      }
})
# output$clustResults<-reactive({
# finishesClustering()
# })
# output$clustResults<-
output$treeviewLink <- renderUI({
      tags$a(href = paste(wwd,"/",sessionID,".jnlp",sep=""), "View resluts with FTreeView")
})

output$downloadLink <- renderUI({
      tags$a(href = paste(wwd,"/",sessionID,".zip",sep=""), "Download clustering results")
})

# observe({
#       if(input$download){
#             system(paste("zip ",sessionID,".zip ",sessionID,".cdt ",sessionID,".gtr ",sessionID,".atr",sep=""))
#             browseURL(paste(wwd,"/",sessionID,".zip",sep=""), browser="konqueror")
#       }
# })


#output$toCluster<-renderTable({
#        if(is.null(input$inputFile)) return(NULL)
#        inputDataTable<-read.table(file=as.character(input$inputFile[1,"datapath"]), sep="\t", header=T, stringsAsFactors=F)
#        head(inputDataTable)[,head(colnames(inputDataTable))]
#       data.frame(x=1:3,y=1:3)
#  })
})




