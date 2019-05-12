# GC % Calculation (for Protein and RNA sequences)

The program follows two phases:

1/ Extract genetic source data from NCBI (in the form of Genbank files)
2/ Calculate GC content %, for RNA or for Protein sources.


## 1. Extract genetic source data

As an example, consider we want to extract data for species 'Pseudopodoces Humilis'. Follow these steps to extract its genetic sequence from NCBI, and prepare it for matching under Stretcher.

This downloads the most recent protein sequence for Pseudopodoces from the NCBI websites. (BASH code, run this in a UNIX terminal)

```
species=Pseudopodoces_humilis

wget -q "ftp://ftp.ncbi.nih.gov/genomes/$species/protein/protein.gbk.gz"
mv -f protein.gbk.gz $species.gbk.gz
gunzip $species.gbk.gz
```

Retrieving the RNA sequence requires a small modification to these NCBI FTP addresses. (Be mindful that the RNA source files are typically order of magnitudes larger than the protein files).

```
species=Pseudopodoces_humilis

wget -q "ftp://ftp.ncbi.nih.gov/genomes/$species/RNA/rna.gbk.gz"
mv -f rna.gbk.gz $species.gbk.gz
gunzip $species.gbk.gz
```



## 2. Calculate GC content

Now we can run two scripts to calculate the GC content. Choose the relevant script depending on whether you downloaded the protein genbank or the RNA genbank files:

```
# ensure the `tmp` folder does not exist
rm -rf tmp

../scripts/gc_01_process_genbank_protein.sh "$species"

```
or for RNA
```
# ensure the `tmp` folder does not exist
rm -rf tmp

../scripts/gc_02_process_genbank_rna.sh "$species"

```
The process_genbank scripts use a number of third party tools (emboss infoseq, gb2tab.py) that were referenced in the main README file. It also calls the gc_03_extract_transcript_number.R file in the scripts directory.

The result is a file named `"$species"_gc.txt`, written to the folder where the commands were called. The file contains 6 columns, and has one row per gene:

```
gene	length	accession		%GC	transcript_label total_transcripts
A1CF	4145	XM_014259502	49.94	2	3
A2M	4757	XM_005531012	50.68	1	1
A4GALT	1948	XM_005531844	51.90	1	1
A4GNT	1179	XM_005529593	56.23	1	1
AAAS	1789	XM_014261811	67.30	2	2
AACS	3246	XM_005524220	44.58	1	1
AADAC	2468	XM_005525148	58.43	1	1
```
The RNA-source method should deliver the same results as the Protein-source method. For our manuscript purposes, we have used the RNA-source data.

