# Scripts


This folder contains the scripts used for the extraction, transformation and modelling of genetic data. Apart from standard UNIX operating system tools, it uses the following open source programs:

- EMBOSS infoseq & stretcher [http://emboss.bioinformatics.nl] (required as a dependency to be installed as a command line tool)
- GB2TAB.py, the command line tool behind FeatureExtract [http://www.cbs.dtu.dk/services/FeatureExtract]  (included in repository)
- Biostrings R Library (part of the BioConductor project) [bioconductor.org].

## Running the scripts


## Matching with Stretcher

The program follows two phases.

1/ Extract genetic data and prepare for Stretcher matching
2/ Stretcher matching.

### 1. Extract Genetic Data and Prepare for Stretcher Matching

As an example, consider we want to extract data for species 'Pseudopodoces Humilis'. Follow these steps to extract its genetic sequence from NCBI, and prepare it for matching under Stretcher.

This downloads the most recent protein sequence for Pseudopodoces from the NCBI websites. (BASH code, run this in a UNIX terminal)

```
species=Pseudopodoces_humilis

wget -q "ftp://ftp.ncbi.nih.gov/genomes/$species/protein/protein.gbk.gz"
mv -f protein.gbk.gz $species.gbk.gz
gunzip $species.gbk.gz
```

Now we use the `gb2tab.py` script to extract the protein sequence from this (hard to otherwise process) genbank file.

```
# create a temporary folder to perform temporary processing in
mkdir tmp 
cd tmp

# assume infoseq is installed systemwide, otherwise add its directory to your $PATH
/usr/bin/python ../../scripts/gb2tab.py -f 'CDS' ../"$species".gbk > "$species"_tabular.txt	
```

This has now generated a tab-separated species information file according to the CDS specification, which looks like this:

```
XP_005516203_1	MAFLPDESRSLPPPPLLNKGSVWLGFVGWLSALLDNAYNHRPVLRSGVHRQVLFATLGCFVGYQLVKRAEYVHAKVDRELFEYVRHHPVDFQAKTEKKRIGELLEDFHPVR	(EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE)	/gene="LOC102099122"/coded_by="XM_005516146.1:87..422"/db_xref="GeneID:102099122" /GenBank_acc="XP_005516203"; /Source="Pseudopodoces humilis (Tibetan ground-jay)"; /feature_type="CDS"; /strand="+";
```

Now we can extract the retrieved protein sequences by using the provided R script, `stretcher_01_extract_protein_sequence.R`.

```
Rscript ../../scripts/stretcher_01_extract_protein_sequence.R "$species"
```

The result is a CSV file with three columns, and looks like this:
```
"accession","sequence","coded_by"
"XP_005516203_1","MAFLPDESRSLPPPPLLNKGSVWLGFVGWLSALLDNAYNHRPVLRSGVHRQVLFATLGCFVGYQLVKRAEYVHAKVDRELFEYVRHHPVDFQAKTEKKRIGELLEDFHPVR","XM_005516146"
"XP_005516204_1","MAAGGRGWFRALALGVSFLKCLLIPAYYSTDFEVHRNWLAITHNLPLSQWYYEATSEWTLDYPPFFAWFEYALSHIAKYFDPQMLVIENLNYASHATIFFQRLSVIFTDTLFIYAVHECCRCVNGKRAAKDILEKPTFILAVLLLWNFGLLIVDHIHFQYNGFLFGLMLLSVARLCQKRYLEGALLFAVLLHFKHIYIYVAPAYGIYLLRSYCFTANNADGSLKWRSFSFLHVTLLGLIVCLVSALSLGPFLVLGQLPQVISRLFPFKRGLCHAYWAPNFWALYNAMDKALTILGLKCNLLDSTKIPKASMTGGLVQEFQHTVLPSVTPLATLVCTFIAILPSVFCLWFKPQGPRGFLQCLVLCALSSFMFGWHVHEKAILLAILPLSLLSIQKVKDAGIYLILATTGHFSLFPLLFTPPELPIKILLMLLFTVYSFSSLKSLFRREKPLLNWLETIYLIQLVPLEIFCEIIFPLTPWKQHFPFVPLLLTSVYCALGITYAWLKLYISVLTERISVRQKAE","XM_005516147"
```

We can now move this file to the 'data vault' to be used for Stretcher.

```
mv "$species"_sequence.csv ../../stretcher-match/data
```



### 2. Stretcher Matching

To now match different species sequences against each other using Stretcher, we need two inputs:

- an input file with `accession | sequence | coded_by` columns as created in Step 1 (all saved in the `data` directory); one file per species that needs to be matched;
- a reference frame file with one column per species to match, which defines the pair-wise accession numbers of protein expressions that need to be matched again each other (provided by earlier BLAST matching).

[! note for RAF — do we have a good way to show reviewers how we got to these reference files?]

As an example, let's match pairwise genes of Homo Sapiens, Gorilla Gorilla and Pan Paniscus against each other. (BASH code, run this in a UNIX terminal)

```
cd stretcher-match

# verify we have data files for Homo, Gorilla and Pan available
ls data

# verify an output directory has been created
mkdir output

```

We have already prepared an R script for matching, `stretcher_02_alignment_protein.R`. Its source onfiguration looks like this

```

### CONFIGURATION HERE

species_homo <- read.csv('data/Homo_sapiens_sequence.csv', stringsAsFactors=FALSE)
species_gorilla <- read.csv('data/Gorilla_gorilla_sequence.csv', stringsAsFactors=FALSE)
species_pan <- read.csv('data/Pan_paniscus_sequence.csv', stringsAsFactors=FALSE)


species_homo['species'] <- 'Homo_sapiens'
species_gorilla['species'] <- 'Gorilla_gorilla'
species_pan['species'] <- 'Pan_paniscus'

species_frame <- rbind(species_homo, species_gorilla,
  species_pan )


### END CONFIGURATION

```
It should be easy to adapt to your needs where necessary. The `species_frame` can be as long as necessary (it has been tested with up to 20 species bound together).

To now provide the script with the list of genes to match, configure the code at the bottom to point to the `example_reference_frame.csv` that we provided


```

### START RUN HERE

reference_frame <- read.csv('example_reference_frame.csv', stringsAsFactors=FALSE)


run_stretcher('Homo_sapiens', 'Gorilla_gorilla')
run_stretcher('Gorilla_gorilla', 'Pan_paniscus')
run_stretcher('Homo_sapiens', 'Pan_paniscus')


### END RUN
```

To run the script, simply call the whole R script like this while in the `stretcher-match` folder:

```
Rscript ../scripts/stretcher_02_alignment_protein.R
```
The script looks over the reference frame for every duo of species that has been given. The first run for instance will run through all pairwise matches of `Homo_sapiens` and `Gorilla_gorilla`. The output is a CSV with 12 columns and looks like this


```
"Homo_sapiens","Gorilla_gorilla","match_length","match_identity","match_similarity","overlap_identity","overlap_matchlength","match_gaps","score","identity","similarity","gaps"
"NM_152486","XM_019009475","718","     651/718 (90.7%)","  656/718 (91.4%)","90.6685236768802","718","         53/718 ( 7.4%)",3302,0.907,0.914,0.074
"NM_015658","XM_019009459","750","     728/750 (97.1%)","  735/750 (98.0%)","97.0666666666667","750","          1/750 ( 0.1%)",3726,0.971,0.98,0.001
"XM_006710600","XM_019014707","665","     590/665 (88.7%)","  590/665 (88.7%)","96.2479608482871","613","         75/665 (11.3%)",2897,0.887,0.887,0.113
"XM_011542248","XM_019014720","771","     646/771 (83.8%)","  651/771 (84.4%)","97.4358974358974","663","        108/771 (14.0%)",3205,0.838,0.844,0.14
"XM_017002584","XM_019033334","790","     345/790 (43.7%)","  348/790 (44.1%)","83.739837398374","369","        421/790 (53.3%)",891,0.437,0.441,0.533
"NM_001142467","XM_004024432","247","     205/247 (83.0%)","  206/247 (83.4%)","87.6068376068376","234","         39/247 (15.8%)",959,0.83,0.834,0.158
"NM_005101","XM_004024431","165","     160/165 (97.0%)","  161/165 (97.6%)","96.969696969697","165","          0/165 ( 0.0%)",813,0.97,0.976,0
```










