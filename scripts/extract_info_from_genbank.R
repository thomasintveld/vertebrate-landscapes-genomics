# package installation
# source("https://bioconductor.org/biocLite.R")
# biocLite("genbankr")

library(genbankr)

gb = readGenBank(system.file("Gallus_gallus.gbk", package="genbankr"))
