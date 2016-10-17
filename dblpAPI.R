#getting stuff faster from dblp
#https://www.r-bloggers.com/accessing-apis-from-r-and-a-little-r-programming/
options(stringsAsFactors = FALSE)
library("httr", lib.loc="~/R/win-library/3.3")
library("jsonlite", lib.loc="~/R/win-library/3.3")
library("XML", lib.loc="~/R/win-library/3.3")
library("plyr", lib.loc="~/R/win-library/3.3")
library("dplyr", lib.loc="~/R/win-library/3.3")


setwd("~/DataScienceResearchInitiative")



#http://dblp.org/search/publ/api for publication queries

url<-"http://dblp.org/"
path<-"search/publ/api"

# Parameter	Description	Default	Example
# q	The query string to search for, as described on a separate page.		...?q=test+search
# format	The result format of the search. Recognized values are "xml", "json", and "jsonp".	xml	...?q=test&format=json
# h	Maximum number of search results (hits) to return. For bandwidth reasons, this number is capped at 1000.	30	...?q=test&h=100
# f	The first hit in the numbered sequence of search results (starting with 0) to return. In combination with the h parameter, this parameter can be used for pagination of search results.	0	...?q=test&h=100&f=300
# c	Maximum number of completion terms (see below) to return. For bandwidth reasons, this number is capped at 1000.	10	...?q=test&c=0

raw.result<- GET("http://dblp.org/search/publ/api?q=wrangl")

this.raw.content <- rawToChar(raw.result$content)


#http://rpubs.com/jsmanij/131030
this.content.list<-xmlToList(this.raw.content)

this.content.frame<- ldply(this.content.list$hits, data.frame)


#update to be sure to use the correct field names - except for author because still need to combine later
#two word ones have to be made into one word - for R - have to edit later
#ReferenceType has to be first to import multiple types in one file others order doesn't matter
content.frame3<- data.frame(ReferenceType = this.content.frame$info.type,
                            Title = this.content.frame$info.title, author = this.content.frame$info.authors.author,
                            author1 = this.content.frame$info.authors.author.1, 
                            author.2 = this.content.frame$info.authors.author.2, 
                            author.3 = this.content.frame$info.authors.author.3, 
                            author4 = this.content.frame$info.authors.author.4, 
                            author5 = this.content.frame$info.authors.author.5, 
                            author6 = this.content.frame$info.authors.author.6, 
                            SecondaryTitle = this.content.frame$info.venue, 
                            Pages = this.content.frame$info.pages, Year = this.content.frame$info.year, 
                             URL = this.content.frame$info.url, 
                            Volume = this.content.frame$info.volume, Number = this.content.frame$info.number, 
                            SecondaryAuthor = this.content.frame$info.author, 
                            Publisher = this.content.frame$info.publisher)
content.frame3<-distinct(content.frame3)


#want to get all authors together and get it basically in the format for TR. 
# first get all authors together separated by ; 
# http://stackoverflow.com/questions/6308933/r-concatenate-row-wise-across-specific-columns-of-dataframe
# example:  data <- within(data,  id <- paste(F, E, D, C, sep="")

content.frame4<- within(content.frame3, Author<- paste(author,author1,author.2, author.3, author4, author5, author6, sep="; " ))

# http://stackoverflow.com/questions/22854112/how-to-skip-a-paste-argument-when-its-value-is-na-in-r
content.frame4$Author<-gsub("NA; ","",content.frame4$Author)

content.frame4$Author<-gsub("NA$","",content.frame4$Author)


#remove NA from other fields

content.frame4[is.na(content.frame4)]<-""

#now drop unwanted columns using df <- subset(df, select = -c(a,c) )  from http://stackoverflow.com/questions/4605206/drop-data-frame-columns-by-name

content.frame5<-subset(content.frame4, select = -c(author,author1,author.2, author.3, author4, author5, author6))


#add in a gsub for the correct reference types
content.frame5$ReferenceType<-gsub("Conference and Workshop Papers","Conference Paper", content.frame5$ReferenceType)
content.frame5$ReferenceType<-gsub("Parts in Books or Collections","Book Section", content.frame5$ReferenceType)
content.frame5$ReferenceType<-gsub("Books and Theses","Book", content.frame5$ReferenceType)
content.frame5$ReferenceType<-gsub("Journal Articles","Journal Article", content.frame5$ReferenceType)


#need tab delimited no rownames and update column names to have the necessary spaces

correctnames<- c("Reference Type","Title", "Secondary Title", "Pages", "Year",  "URL", "Volume", "Number", "Secondary Author", "Publisher", "Author")

# if only one type of reference specify at top *Generic to top of file also add a vector of correct column names
#write("*Generic","dblptestnew.txt")
#write.table(content.frame5,"dblptestnew.txt",append = T, quote=F,sep = "\t",row.names = F,col.names=correctnames, fileEncoding = "UTF-8")

#if multiple types use this one
write.table(content.frame5,"dblp30wrangl.txt", quote=F,sep = "\t",row.names = F,col.names=correctnames, fileEncoding = "UTF-8")
