options <- commandArgs(trailingOnly = TRUE)


species=options[[1]]

#df <- read.table(paste0(species, '_infoseq_R.txt'), header=TRUE, sep="|", stringsAsFactors=FALSE)

df_al <- readLines(paste0(species, '_infoseq_R.txt'))

transcript_nr <- sapply(1:length(df_al), function(i){

  res <- "1"

  descstring <- df_al[i]

  m <- regexpr( "(transcript|) variant (X|)([0-9]+)",descstring)
  x <- regmatches(descstring,m)

  if(length(x)==0 ){
    return(res)
  }

  x <- gsub('X', '', x[1])
  x <- gsub('transcript', '', x)
  x <- gsub('variant', '', x)
  x <- gsub(' ', '', x)

  if(length(x)==0 | is.na(x)| is.null(x)){
    return(res)
  }

  return(x)

})

if(length(transcript_nr) != length(df_al)){
  cat('ERROR NOT EQUAL LENGTH')
  q()
}
transcript_nr <- as.numeric(transcript_nr)
transcript_nr[1] <- 'transcript_nr'

write.table(transcript_nr, file=paste0(species, '_transcript.txt'),quote=FALSE, col.names=FALSE,row.names=FALSE, sep='\t' )
