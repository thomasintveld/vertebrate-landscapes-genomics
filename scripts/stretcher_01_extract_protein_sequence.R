options <- commandArgs(trailingOnly = TRUE)


species=options[[1]]

df <- read.table(paste0(species, '_tabular.txt'), sep='\t', header=FALSE, stringsAsFactors=FALSE)

resframe <- lapply(1:nrow(df), function(i){
  cat(i)
  cat('\n')
  vecx <- df[i,]
  textmatch <- vecx$V4
  m <- regexpr('coded_by=(XM|XP|XR|NM|NP|XR)_([0-9]*)', textmatch)
  codegene <- regmatches(textmatch, m)

  if(length(codegene)==0){
    codegene <- ''
  } else {
  codegene <- gsub('coded_by=', '', codegene[[1]])
}

  res <- data.frame(accession=vecx$V1, sequence=vecx$V2, coded_by=codegene, stringsAsFactors=FALSE)
  return(res)
})


resframe_df <- as.data.frame(do.call(rbind, resframe), stringsAsFactors=FALSE)

write.csv(resframe_df, file=paste0(species, '_sequence.csv'),  row.names=FALSE)
