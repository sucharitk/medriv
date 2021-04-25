# medriv
processing pipeline and statistical analysis code for binocular rivalry in long-term meditators paper

Katyal, S., & Goldin, P. (2021). The neural correlates of non-judgmental perception induced through meditation. Annals of the New York Academy of Sciences, accepted.


directory structure:

'processing' contains matlab code for processing the minimally pre-processed data. the main script is medriv_riv_analysis.m, which calls all the other files in the directory
'stats' contains the R code for doing the analysis and generating the results figures in the paper 
'helper' contains additional .m files called by the matlab code
