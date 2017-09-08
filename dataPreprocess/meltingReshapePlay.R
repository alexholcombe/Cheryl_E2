
#https://stackoverflow.com/questions/23945350/reshaping-wide-to-long-with-multiple-values-columns
dw <- read.table(header=T, text='
 sbj f1.avg f1.sd f2.avg f2.sd  blabla
                 A   10    6     50     10      bA
                 B   12    5     70     11      bB
                 C   20    7     20     8       bC
                 D   22    8     22     9       bD
                 ')
reshape(dw, direction='long', 
        varying=c('f1.avg', 'f1.sd', 'f2.avg', 'f2.sd'), 
        timevar='var',
        times=c('f1', 'f2'),
        v.names=c('avg', 'sd'),
        idvar=c('sbj','blabla'))


#THESE ARE FRAGMENTS MOST OF WHICH WON'T WOR,. ULTIMATELY RESHAPE DIDN'T WORK FOR ME

dw <- read.table(header=T, text='
 sbj f1.avg f1.sd f2.avg f2.sd  blabla
                 A   10    6     50     10      bA
                 B   12    5     70     11      bB
                 C   20    7     20     8       bC
                 D   22    8     22     9       bD
                 ')

dw %>% 
  gather(v, value, f1.avg:f2.sd) %>% 
  separate(v, c("var", "col")) %>% 
  arrange(sbj) %>% 
  spread(col, value)

idColumnsThatAreSameForLeftAndRightTargets<- colnames(ee)[1:23]
idColsMinimal<-colnames(ee)[1:6]
#First melt only answer, then melt only response, then only correct, then cueSerialPos, then responsePosRel, then merge back together
columnsToMelt<- colnames(ee)[24:33]

#Make a simpler dataframe
dw<- filter(ee,subject=="T1") #,wordEccentricity==6)
dw<-ee #%>% select(subject,wordEccentricity,trialnum, answerLeft:responsePosRelRight)
dl<-reshape(dw, direction='long', 
            varying= columnsToMelt, 
            timevar='side',
            times=c('left', 'right'),
            v.names=c('answer', 'response','correct','cueSerialPos','responsePosRel'),
            idvar=idColsMinimal)
rownames(dl)<-NULL
write.csv(dl, file="dataRaw/T1.csv",row.names=FALSE)


reshape(df, direction='long', 
        varying= columnsToMelt, 
        timevar='side',
        times=c('left', 'right'),
        v.names=c('answer', 'response','correct','cueSerialPos','responsePosRel'),
        idvar=idColumnsThatAreSameForLeftAndRightTargets)

#Make a simpler dataframe
dw<-ee %>% filter(subject=="T1",wordEccentricity<7) %>% select(subject,wordEccentricity,trialnum, answerLeft:responsePosRelRight)
dl<-reshape(dw, direction='long', 
            varying= columnsToMelt, 
            timevar='side',
            times=c('left', 'right'),
            v.names=c('answer', 'response','correct','cueSerialPos','responsePosRel'),
            idvar=c("subject","trialnum","wordEccentricity"))
rownames(dl)<-NULL



write.csv(dl,"cherylCheckThisLongIsCorrect.csv")
dl<-reshape(df, direction='long', 
            varying= columnsToMelt, 
            timevar='side',
            times=c('left', 'right'),
            v.names=c('answer', 'response','correct','cueSerialPos','responsePosRel'),
            idvar=idColsMinimal)
#WORKS
dl<-reshape(df, direction='long', 
            varying= c("left.cueSerialPos","right.cueSerialPos"), 
            timevar='side',
            times=c('left', 'right'),
            v.names=c('cueSerialPos'),
            idvar=idColsMinimal)
#DOESNT WORK
dl<-reshape(df, direction='long', 
            varying= c("left.cueSerialPos","right.cueSerialPos",'left.correct','right.correct'), 
            timevar='side',
            times=c('left', 'right'),
            v.names=c('cueSerialPos','correct'),
            idvar=idColsMinimal)
#WORKS. So, one variable works but two doesn't. Use tidyr gather etc. instead
dl<-reshape(df, direction='long', 
            varying= c('left.correct','right.correct'), 
            timevar='side',
            times=c('left', 'right'),
            v.names=c('correct'),
            idvar=idColsMinimal)
#times specifies values that are to be used in the created var column, and v.names are pasted onto these values to get column names in the wide format for mapping to the result.




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

