
# setwd("~/Desktop/Analysis/data")
rawDataPath<- file.path( 'dataRaw/dataE2' ) #Cheryl-prepared files


turnRawPsychopyOutputIntoMeltedDataframe<- function(df) {
  
  
}
df<-dfThis
library(dplyr)

dealWithRightResponseFirstMess<- function(df) {
  #cheryl RIGHT SOMETHING TO EXPLAIN ALL THIS HERE
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

    #dfThis<- turnRawPsychopyOutputIntoMeltedDataframe(rawDataLoad)

    tryCatch(
      dfAll<-rbind(dfAll,dfThis), #if fail to bind new with old,
      error=function(e) { #Give feedback about how the error happened
        cat(paste0("Tried to merge but error:",e) )
      } )
  }
  return(dfAll)
}


E<- readInAllFiles(rawDataPath)
ee<- dealWithRightResponseFirstMess(E)

require(reshape2)
idColumnsThatAreSameForLeftAndRightTargets<- colnames(ee)[1:23]
#First melt only answer, then melt only response, then only correct, then cueSerialPos, then responsePosRel, then merge back together
columnsToMelt<- colnames(ee)[24:33]

#Step through each pair of columns, melt, then merge
for (i in seq(1,length(columnsToMelt),2)) {
  colsToMelt<- columnsToMelt[ seq(i,i+1) ]
  print(colsToMelt)
  dfThis<- select(df,c(idColumnsThatAreSameForLeftAndRightTargets,colsToMelt) )
  
  #Assume that it's of the form answerLeft or xxxxLeft and cut off the last four letters ("Left")
  newValueName<- substr( colsToMelt[1], 1, nchar(colsToMelt[1])-4 )
  meltedThis<- melt(dfThis, id=idColumnsThatAreSameForLeftAndRightTargets, value.name=newValueName) 
  #melt created a new variable called "variable" which we want to call targetSide
  meltedThis<- rename(meltedThis, targetSide = variable)
}
  
ff<- melt(ee, id=idColumnsThatAreSameForLeftAndRightTargets, value.name="answer")

