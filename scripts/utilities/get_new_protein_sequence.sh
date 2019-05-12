#!/bin/bash
species=$1


cd ~/genomics/aggregate-protein


  wget -q "ftp://ftp.ncbi.nih.gov/genomes/$species/protein/protein.gbk.gz"
  	mv -f protein.gbk.gz $species.gbk.gz
  	gunzip $species.gbk.gz


cd tmp

/usr/bin/python ../../scripts/gb2tab.py -f 'CDS' ../"$species".gbk > "$species"_tabular.txt

Rscript ../../scripts/20170625_extract_protein_sequence.R "$species"

mv "$species"_sequence.csv ../../stretcher-match/data
