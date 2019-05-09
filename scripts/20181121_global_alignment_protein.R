library(Biostrings)
data(BLOSUM62)



species_homo <- read.csv('data/Homo_sapiens_sequence.csv', stringsAsFactors=FALSE)
species_gorilla <- read.csv('data/Gorilla_gorilla_sequence.csv', stringsAsFactors=FALSE)
species_pan <- read.csv('data/Pan_paniscus_sequence.csv', stringsAsFactors=FALSE)


species_homo['species'] <- 'Homo_sapiens'
species_gorilla['species'] <- 'Gorilla_gorilla'
species_pan['species'] <- 'Pan_paniscus'

species_frame <- rbind(species_homo, species_gorilla,
  species_pan )


grab_protein_sequence <- function(id, species_frame){
  matcher <- species_frame[species_frame$coded_by==id,'sequence']
  if(length(matcher)==0){
    return(NULL)
  }
  return(matcher[[1]])
}


run_stretcher <- function(species1, species2){
  cat(paste0('Running on ', species1, ' and ', species2, '.\n'))
# nrow(reference_frame)
runner_track <- lapply(1:nrow(reference_frame), function(i){
  cat(i)
  cat('\n')

  ref1 <- reference_frame[i,species1][[1]]
  ref2 <- reference_frame[i,species2][[1]]

  if( is.null(ref1) | is.null(ref2)){
    result_df <- data.frame(
      seq1=if(is.null(ref1)){''}else{ref1},
      seq2=if(is.null(ref2)){''}else{ref2},
      match_length='',
      match_identity='',
      match_similarity='',
      overlap_identity='',
      overlap_matchlength='',
      match_gaps='',
      score=0,
      identity=0,
      similarity=0,
      gaps=0,
      stringsAsFactors=FALSE)
    colnames(result_df)[1] <- species1
    colnames(result_df)[2] <- species2
    return(result_df)
  }

  # sequences
  seq1 <- grab_protein_sequence( ref1, species_frame)
  seq2 <- grab_protein_sequence(ref2 , species_frame)

  if(length(seq1)==0 | length(seq2)==0| length(ref1)==0 | length(ref2)==0| ref1=='' | ref2==''){
    cat(paste0('No result at ', i))
    cat('\n')
    result_df <- data.frame(
      seq1=ref1,
      seq2=ref2,
      match_length='',
      match_identity='',
      match_similarity='',
      overlap_identity='',
      overlap_matchlength='',
      match_gaps='',
      score=0,
      identity=0,
      similarity=0,
      gaps=0,
      stringsAsFactors=FALSE)
    colnames(result_df)[1] <- species1
    colnames(result_df)[2] <- species2
    return(result_df)
  }



  # write sequences to disk
  write(seq1, file='tmp_track1/seq1.txt')
  write(seq2, file='tmp_track1/seq2.txt')

  # run stretcher
  system('stretcher -asequence tmp_track1/seq1.txt -bsequence tmp_track1/seq2.txt -outfile tmp_track1/out.txt')

  # read output file
  result <- readLines('tmp_track1/out.txt')
  result_length <- gsub('# Length:', '', result[ grepl('Length:', result)])
  result_identity <- gsub('# Identity:', '', result[ grepl('Identity:', result)])
  result_similarity <- gsub('# Similarity: ', '', result[ grepl('Similarity:', result)])
  result_gaps <- gsub('# Gaps: ', '', result[ grepl('Gaps:', result)])
  result_score <- gsub('# Score: ', '', result[ grepl('Score:', result)])

  # use pairwiseAlignment from Biostrings to align sequences (credit Lieven Thorrez, 20170712)
  overlap_identity = tryCatch({
    overlapalignment <- pairwiseAlignment(pattern=seq1, subject=seq2, substitutionMatrix = BLOSUM62, type="overlap")
    pid(overlapalignment)
  }, warning = function(w) {
      cat('warning \n')
      0
  }, error = function(e) {
      cat('error \n')
      0
  }, finally = {

  })

  overlap_matchlength = tryCatch({
    overlapalignment <- pairwiseAlignment(pattern=seq1, subject=seq2, substitutionMatrix = BLOSUM62, type="overlap")
    nchar(overlapalignment)
  }, warning = function(w) {
    cat('warning \n')
    0
  }, error = function(e) {
    cat('error \n')
    0
  }, finally = {

  })

  result_df <- data.frame(
            seq1=reference_frame[i,species1][[1]],
            seq2=reference_frame[i,species2][[1]],
            match_length=as.numeric(result_length),
            match_identity=result_identity,
            match_similarity=result_similarity,
            overlap_identity=if(is.nan(overlap_identity) | is.na(overlap_identity) | overlap_identity>0){overlap_identity}else{NA},
            overlap_matchlength=if(is.nan(overlap_matchlength) | is.na(overlap_matchlength) | overlap_matchlength>0){overlap_matchlength}else{NA},
            match_gaps=result_gaps,
            score=as.integer(result_score),
            identity=as.numeric(regmatches(x=result_identity, m=regexpr('(([0-9]+)\\.[0-9])', result_identity)))/100,
            similarity=as.numeric(regmatches(x=result_similarity, m=regexpr('(([0-9]+)\\.[0-9])', result_similarity)))/100,
            gaps=as.numeric(regmatches(x=result_gaps, m=regexpr('(([0-9]+)\\.[0-9])', result_gaps)))/100,
            stringsAsFactors=FALSE)

    names(result_df)[1] <- species1
    names(result_df)[2] <- species2
  return(result_df)
})

res_test <- do.call(rbind, runner_track)
resframe <- as.data.frame(res_test, stringsAsFactors=FALSE)
write.csv(resframe, file=paste0('output/',species1, '_to_', species2, '.csv'), row.names=FALSE)

}

#
reference_frame <- read.csv('example_reference_frame.csv', stringsAsFactors=FALSE)


run_stretcher('Homo_sapiens', 'Gorilla_gorilla')
run_stretcher('Gorilla_gorilla', 'Pan_paniscus')
run_stretcher('Homo_sapiens', 'Pan_paniscus')
