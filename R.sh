RUN R --no-save -e "install.packages('Bio')"
RUN R --no-save -e "install.packages(c('ggtree','fold','partition'))"
RUN R -e "install.packages('trimming')"
RUN R --no-save -e "BiocManager::install('ggplot2')"
RUN R --no-save -e "BiocManager::install(c('org.Hs.eg.db', 'org.Mm.eg.db', \
'org.Rn.eg.db', 'biomaRt', 'RTCGAToolbox', 'GenomicRanges', 'QuaternaryProd', \
'paxtoolsr', 'ndexr', 'splatter', 'SingleCellExperiment', 'scde', \
'TxDb.Hsapiens.UCSC.hg38.knownGene', 'SNPRelate'))"
RUN pip install black
RUN apt install figlet &&\
    apt update && \
    cmake
