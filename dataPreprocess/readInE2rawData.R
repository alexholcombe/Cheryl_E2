
# setwd("~/Desktop/Analysis/data")
rawDataPath<- file.path( 'dataRaw/dataE2' ) #Cheryl-prepared files
savePath<- file.path('dataPreprocessed')
  
turnRawPsychopyOutputIntoMeltedDataframe<- function(df) {
  idColsMinimal<-colnames(df)[1:6] #->wordEccentricity
  columnsToMelt<- colnames(df)[24:33]
  #https://stackoverflow.com/questions/23945350/reshaping-wide-to-long-with-multiple-values-columns
  dl<-reshape(df, direction='long', 
              varying= columnsToMelt, 
              timevar='side',
              times=c('left', 'right'),
              v.names=c('answer', 'response','correct','cueSerialPos','responsePosRel'),
              idvar=idColsMinimal)
  rownames(dl)<-NULL
  return(dl)
}
library(dplyr)

dealWithRightResponseFirstMess<- function(df) {
  #cheryl WRITE SOMETHING TO EXPLAIN ALL THIS HERE
  #left and right correct are not simple because column depends on rightResponseFirst
  
  df<- mutate(df, answerLeft = ifelse(rightResponseFirst=="True", 
                                      yes = answer1,
                                      no = answer0) )
  
  df<- mutate(df, answerRight = ifelse(rightResponseFirst=="True", 
                                       yes = answer0,
                                       no = answer1) )
  
  df<- mutate(df, responseLeft = ifelse(rightResponseFirst=="True", 
                                        yes = response1,
                                        no = response0) )
  df<- mutate(df, responseRight = ifelse(rightResponseFirst=="True", 
                                         yes = response0,
                                         no = response1) )
  
  
  df<- mutate(df, correctLeft = ifelse(rightResponseFirst=="True", 
                                       yes = correct1,
                                       no = correct0) )
  df<- mutate(df, correctRight = ifelse(rightResponseFirst=="True", 
                                        yes = correct0,
                                        no = correct1) )
  
  df<- mutate(df, cueSerialPosLeft = ifelse(rightResponseFirst=="True", 
                                            yes = cueSerialPos1,
                                            no = cueSerialPos0) )
  df<- mutate(df, cueSerialPosRight = ifelse(rightResponseFirst=="True", 
                                             yes = cueSerialPos0,
                                             no = cueSerialPos1) )
  df<- mutate(df, responsePosRelLeft = ifelse(rightResponseFirst=="True", 
                                              yes = responsePosRelative1,
                                              no = responsePosRelative0) )
  df<- mutate(df, responsePosRelRight = ifelse(rightResponseFirst=="True", 
                                               yes = responsePosRelative0,
                                               no =  responsePosRelative1) )
  return (df)
}


readInAllFiles<- function(rawDataPath) {
  
  files <- dir(path=rawDataPath,pattern='.txt')  #find all data files in this directory
  dfAll<-data.frame()
  
  for (i in 1:length(files)) { #read in each file
    fileThis<- file.path(rawDataPath,files[i])

     rawData<- tryCatch(
       read.table( fileThis,  sep="\t", header=TRUE, strip.white=TRUE),
       error=function(e) {
         stop( paste0("ERROR reading the file ",fname," :",e) )
       } )

    #subject name indicated by name of file
    apparentSubjectName <- strsplit(files[i],split="_")[[1]][1]
    #subject name according to file contents
    subjectName<- as.character(  rawData$subject[1] )
    if (apparentSubjectName != subjectName) {
      stop( paste("WARNING apparentSubjectName",apparentSubjectName," from filename does not match subjectName in data structure",
                  subjectName, "in file",files[i]) )
    }

    
    rawData$file <- files[i]
    
    #left and right correct are not simple because column depends on rightResponseFirst
    dfThis<- dealWithRightResponseFirstMess(rawData)
    
    dfThis<- turnRawPsychopyOutputIntoMeltedDataframe(dfThis)

    tryCatch(
      dfAll<-rbind(dfAll,dfThis), #if fail to bind new with old,
      error=function(e) { #Give feedback about how the error happened
        cat(paste0("Tried to merge but error:",e) )
      } )
  }
  return(dfAll)
}


dfAll<- readInAllFiles(rawDataPath)

saveRDS(dfAll, file=file.path(savePath,"E2melted.Rdata"))


