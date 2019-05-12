# Vertebrate Exome Landscape Genomics

This folder contains the scripts used for the extraction, transformation and modelling of genetic data. It serves as an appendix to the manuscript "GC content of vertebrate exome landscapes reveal areas of accelerated protein evolution", with authors Raf Huttener; Lieven Thorrez; Thomas In't Veld; Mikaela Granvik; Lukas Snoeck; Leentje Van Lommel; Frans Schuit. (EVOB-D-19-00068)


Script contributors:
- Thomas in't Veld (intveld at kuleuven.be), Corresponding Author for these scripts
- Raf Huttener (raf.huttener at kuleuven.be)
- Lieven Thorrez (lieven.thorrez at kuleuven.be).


Apart from standard UNIX operating system tools, the scripts use the following open source programs:

- EMBOSS infoseq & stretcher [http://emboss.bioinformatics.nl] (required as a dependency to be installed as a command line tool)
- GB2TAB.py, the command line tool behind FeatureExtract [http://www.cbs.dtu.dk/services/FeatureExtract]  (included in repository)
- Biostrings R Library (part of the BioConductor project) [bioconductor.org].

## Running the scripts

We have provided run-throughs and tutorials for the three main method parts of our manuscript:

- Calculating GC% and transcript length for the relevant genes [README_1_GC_content](https://github.com/thomasintveld/vertebrate-landscapes-genomics/blob/master/scripts/README_1_GC_content.md)
- Calculating GARP and FYMINK percentages [README_2_GARP_FYMINK](https://github.com/thomasintveld/vertebrate-landscapes-genomics/blob/master/scripts/README_2_GARP_FYMINK.md)
- Calculating protein overlap percentages with Stretcher Matching [README_3_stretcher](https://github.com/thomasintveld/vertebrate-landscapes-genomics/blob/master/scripts/README_3_stretcher.md)


