qsub -keo -q long -lnodes=1:ppn=1:cuda10 -v MYARGUMENTS="6 ../../src-test/ABC_SMC_RNAseq_fixedparams.jl 1 6 $ABCDATA/ABC_output/RNAseq/lisi_high_var_2i $ABCDATA/ABC_output/log_files/lisi_high_var_2i.log" run_ABC.sh
