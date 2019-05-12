library(stringr)


options <- commandArgs(trailingOnly = TRUE)


filename=options[[1]]

#filename='Pseudopodoces_humilis_sequence.csv'



df <- read.csv(paste0('data/', filename, '_sequence.csv'), stringsAsFactors=FALSE)

# garp occurrence
df['GARP_count'] <- str_count(df$sequence, '[GARP]')
df['FYMINK_count'] <- str_count(df$sequence, '[FYMINK]')
df['SEQ_length'] <- nchar(trimws(df$sequence))


df['GARP_pct'] <- df$GARP_count / df$SEQ_length
df['FYMINK_pct'] <- df$FYMINK_count / df$SEQ_length

write.csv(df, paste0('output/', filename), row.names=FALSE)
