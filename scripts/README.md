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
