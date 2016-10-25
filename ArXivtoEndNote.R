#from ArXiv to EndNote
#https://ropensci.org/tutorials/arxiv_tutorial.html

library("aRxiv", lib.loc="~/R/win-library/3.3")
library(stringr)




DataInteg<- arxiv_search('ti:"data integration" AND submittedDate:[2012 TO 2016]', limit=100)

View(DataInteg)


ReferenceType<-as.vector(rep("Manuscript",length(DataInteg$id)))

DataInteg$abstract<-str_replace_all(DataInteg$abstract, "[\r\n\t]" , " ")
DataInteg$title<-str_replace_all(DataInteg$title, "[\r\n\t]" , " ")
DataInteg$comment<-str_replace_all(DataInteg$comment, "[\r\n\t]" , " ")
DataInteg$journal_ref<-str_replace_all(DataInteg$journal_ref, "[\r\n\t]" , " ")

DataIntegO<-cbind(ReferenceType=ReferenceType,DataInteg$id, DataInteg$title,strtrim(DataInteg$submitted,4),DataInteg$link_abstract,
                  DataInteg$authors,DataInteg$abstract,DataInteg$affiliations,paste(DataInteg$comment,DataInteg$journal_ref))

#manuscript number didn't fly. Not sure why

correctnames<- c("Reference Type","Number", "Title", "Year", "URL", "Author","Abstract","Author Address","Notes")

write.table(DataIntegO,"ArXivDataInteg.txt", quote=F,sep = "\t",row.names = F,col.names=correctnames, fileEncoding = "UTF-8")
