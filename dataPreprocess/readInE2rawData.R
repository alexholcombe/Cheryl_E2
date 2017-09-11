
# setwd("~/Desktop/Analysis/data")
rawDataPathE2<- file.path( 'dataRaw/dataE2' ) #Cheryl-prepared files
rawDataPathE1<- file.path( 'dataRaw/dataE1' ) #Cheryl-prepared files
rawDataPath<- rawDataPathE1
exp<-"E2"
savePath<- file.path('dataPreprocess')

library(dplyr)
library(tidyr)

renameForGather<- function(df) {
  df<- dplyr::rename(df,left.answer=answerLeft,right.answer=answerRight,
             left.response=responseLeft,right.response=responseRight,
         left.correct=correctLeft,right.correct=correctRight,
         left.cueSerialPos=cueSerialPosLeft,
         right.cueSerialPos=cueSerialPosRight,left.responsePosRel=responsePosRelLeft,
         right.responsePosRel=responsePosRelRight) 
  if (exp=="E1") {
    df<-dplyr::rename(df, wordEccentricity = wordEcc)
  }
  df<-select(df,   -one_of("responsePosRelative0","responsePosRelative1","response0","response1",
                           "correct0","correct1","answer0","answer1") )
  return(df) 
}

turnRawPsychopyOutputIntoMeltedDataframe<- function(df) {
  idColsMinimal<-colnames(df)[1:6] #->wordEccentricity
  if (exp=="E1") {
    columnsToMelt<- colnames(df)[17:26]
  } else {
    columnsToMelt<- colnames(df)[24:33]
  }
  #https://stackoverflow.com/questions/23945350/reshaping-wide-to-long-with-multiple-values-columns
dl<-  df %>% 
    gather(v, value, left.answer:right.responsePosRel) %>% 
    separate(v, c("var", "col")) %>% 
    arrange(subject,trialnum,wordEccentricity) %>% 
    spread(col, value) %>% rename(side=var)
  rownames(dl)<-NULL
  return(dl)
}


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
    filename<-files[i]
    if (exp=="E1") { # in E1 Cheryl indicated the session with a dash, like "12-"
      apparentSubjectName<- strsplit(filename,split="-")[[1]][1]
    } else {
      apparentSubjectName <- strsplit(filename,split="_")[[1]][1]
    }
    print(paste("Apparent subject name about to load is",apparentSubjectName))
    #subject name according to file contents
    subjectName<- as.character(  rawData$subject[1] )
    if (exp=="E1") {
      subjectName <- strsplit(filename,split="-")[[1]][1]  #remove session number
      rawData$subject<- subjectName #Don't keep session number in subject field because then will be analyzed seaprately
      rawData$sesssion<- strsplit(filename,split="-")[[1]][2]
    }
    if (apparentSubjectName != subjectName) {
      stop( paste("WARNING apparentSubjectName",apparentSubjectName," from filename does not match subjectName in data structure",
                  subjectName, "in file",files[i]) )
    }

    
    rawData$file <- filename
    
    #left and right correct are not simple because column depends on rightResponseFirst
    dfThis<- dealWithRightResponseFirstMess(rawData)
    
    dfThis<- renameForGather(dfThis)
    
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

dfAll$numItemsInStream<-26

#R code needs
# $targetSP, the serial position of the target on that trial
# $SPE, the serial position error
dfAll$targetSP<- dfAll$cueSerialPos
dfAll$SPE<- dfAll$responsePosRel
E2melted<-dfAll
saveFileName<- paste0(exp,"melted.Rdata")
saveRDS(dfAll, file=file.path(savePath,saveFileName))


