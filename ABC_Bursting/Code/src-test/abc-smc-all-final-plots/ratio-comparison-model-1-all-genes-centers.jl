using PyPlot
using ABC_Bursting
using PyCall, PyPlot; @pyimport seaborn as sns
using PyCall, PyPlot; @pyimport pandas as pd
# genes = ["ENSMUSG00000003032", "ENSMUSG00000012396", "ENSMUSG00000018604", "ENSMUSG00000020717", "ENSMUSG00000021255", "ENSMUSG00000021835", "ENSMUSG00000022528", "ENSMUSG00000025056", "ENSMUSG00000038793", "ENSMUSG00000048402", "ENSMUSG00000051176"]
xes = ["ENSMUSG00000006398", "ENSMUSG00000027715", "ENSMUSG00000029177", "ENSMUSG00000029472", "ENSMUSG00000030867", "ENSMUSG00000041431","ENSMUSG00000003032", "ENSMUSG00000012396", "ENSMUSG00000018604", "ENSMUSG00000020717", "ENSMUSG00000021255", "ENSMUSG00000021835", "ENSMUSG00000022528", "ENSMUSG00000025056", "ENSMUSG00000038793", "ENSMUSG00000048402", "ENSMUSG00000051176"]
genes =vcat(xes,xes)
# genes = [ "ENSMUSG00000025056","ENSMUSG00000021835","ENSMUSG00000048402", "ENSMUSG00000048402",  "ENSMUSG00000020717","ENSMUSG00000051176"]
# colors = ["darkblue", "blue","lightblue", "orangered", "red", "darkred"]
# real_names = ["Nr0b1 in serum",  "Bmp4 in serum", "Gli2 in serum","Zfp42 in 2i", "Pecam1 in 2i", "Gli2 in 2i"]
# markers = ["+" , "*" , "^","+" , "*" , "^"]
sampled_parameter_combinations_serum = []
n_samples = 500
n_tester = 500

all_r_deact_deg_serum = []
all_r_act_deg_serumm = []
all_centroid_x_serum = []
all_centroid_y_serum = []

genekind = ["2i","2i","2i","2i","2i","2i","serum","serum","serum","serum","serum","serum","serum","serum","serum","serum","serum"]
# genekind = ["serum","serum","serum","serum","serum","serum","2i","2i","2i","2i","2i","2i","2i","2i","2i","2i","2i"]
genekind =vcat(genekind,genekind)

# genekind = ["2i","2i","2i","2i","2i","2i"]
# genekind = ["serum","serum","serum","serum","serum","serum","serum","serum","serum","serum","serum"]
# datakind = ["2i","2i","2i","2i","2i","2i"]
# datakind = ["serum","serum","serum","serum","serum","serum"]
# datakind = ["2i","2i","2i","2i","2i","2i","2i","2i","2i","2i","2i"]
# datakind = ["serum","serum","serum","serum","serum","serum","serum","serum","serum","serum","serum"]
# datakind = ["serum","serum","serum","serum","serum","serum","serum","serum","serum","serum","serum","serum","serum","serum","serum","serum","serum"]
# datakind = ["2i","2i","2i","2i","2i","2i","2i","2i","2i","2i","2i","2i","2i","2i","2i","2i","2i"]
datakind2 = ["2i","2i","2i","2i","2i","2i","serum","serum","serum","serum","serum","serum","serum","serum","serum","serum","serum"]
datakind = ["serum","serum","serum","serum","serum","serum","2i","2i","2i","2i","2i","2i","2i","2i","2i","2i","2i"]
datakind=vcat(datakind,datakind2)
colors=[]
markers=[]

for i in 1:length(genekind)
      if genekind[i] == "2i"
            push!(markers,"o")
            if datakind[i] =="2i"
                  push!(colors,"salmon")
            else
                  push!(colors,"cornflowerblue")
            end
      else
            push!(markers,"+")
            if datakind[i] =="2i"
                  push!(colors,"salmon")
            else
                  push!(colors,"cornflowerblue")
            end
      end
end

counter = 0
for name in genes
      counter=counter+1
      path_to_file_serum =  string("/project/home17/er4517/project_3/gene_bursting/ABC_Bursting/Data/ABC_output/RNAseq/explore_distr/model_1/all_high_var_in_",genekind[counter],"_genes_in_",datakind[counter],"/model1_",name,"_0.1_500_250000_",genekind[counter],"_genes_",datakind[counter],"_data.txt")
      data_file_serum=read_one_m1(path_to_file_serum,  3, n_samples,3)
      cum_posterior_serum = Vector(n_samples)
      cumsum!(cum_posterior_serum, data_file_serum[6])
      sample_rand_serum = rand(n_tester)
      winner_inds_serum = []
      for s in sample_rand_serum
          for i in 1:length(cum_posterior_serum)
                if s<cum_posterior_serum[i]
                  push!(winner_inds_serum, [data_file_serum[1][i], data_file_serum[2][i], data_file_serum[3][i]])
                  break
                end
          end
      end
      push!(sampled_parameter_combinations_serum, winner_inds_serum)
end


for name in 1:length(genes)
      acts_serum = []
      deacts_serum = []
      degs_serum = []
      for i in 1:length(sampled_parameter_combinations_serum[name])
            push!(acts_serum,convert(Float64,sampled_parameter_combinations_serum[name][i][1]))
            push!(deacts_serum,convert(Float64,sampled_parameter_combinations_serum[name][i][2]))
            push!(degs_serum,convert(Float64,sampled_parameter_combinations_serum[name][i][3]))
      end
      a=convert(Array{Float64,1},acts_serum)
      b=convert(Array{Float64,1},deacts_serum)
      c=convert(Array{Float64,1},degs_serum)
      a2= [10^n for n in a]
      b2= [10^n for n in b]
      c2= [10^n for n in c]
      r_deact_deg_serum =  log10.((b2)./(c2))
      r_act_deg_serum =  log10.((a2)./(c2))
      push!(all_r_deact_deg_serum, r_deact_deg_serum)
      push!(all_r_act_deg_serumm, r_act_deg_serum)
      centroid_x_serum ,centroid_y_serum = (sum(r_deact_deg_serum)/length(r_deact_deg_serum), sum(r_act_deg_serum)/length(r_act_deg_serum))
      push!(all_centroid_x_serum, centroid_x_serum)
      push!(all_centroid_y_serum, centroid_y_serum)
end

# centroid_x_2i ,centroid_y_2i = (sum(r_deact_deg_2i)/length(r_deact_deg_2i), sum(r_act_deg_2i)/length(r_act_deg_2i))
fig,ax = PyPlot.subplots()
      # sns.regplot([-1.5,2.5],[0.0,-2.0],color = "white",fit_reg=false)
      for name in 1:length(genes)
            PyPlot.scatter([all_centroid_x_serum[name]],[all_centroid_y_serum[name]], label=string(genes[name]), color = colors[name],marker = markers[name])
            # sns.regplot(x=all_r_deact_deg_serum[name],y=all_r_act_deg_serumm[name],label=string(genes[name]), scatter = true)
      end

      # ax[:legend]()
      ax[:set_ylabel]("log(act/deg)")
      ax[:set_xlabel]("log(deact/deg)")
      # ax[:set_title](string(" params sampled for ", genes,))
      ax[:set_ylim]([-2.5,1])
      ax[:set_xlim]([-1.5,2.5])
savefig(string("/project/home17/er4517/project_3/gene_bursting/ABC_Bursting/plots/validate/",string(length(genes)),"_genes_ratios_center.png"))
