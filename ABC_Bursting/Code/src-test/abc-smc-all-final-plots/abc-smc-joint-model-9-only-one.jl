using PyCall, PyPlot; @pyimport pandas as pan
@pyimport seaborn as sns
using ABC_Bursting
using StatPlots
using KernelDensity

name="xyz"
a3_2i,b3_2i,c3_2i,d3_2i,di3_2i,w3_2i = 0,0,0,0,0,0
fileending_2i="validate_model_9_david_100_02_500"
nsamples = 500
path_to_file_2i = string("/project/home17/er4517/project_3/gene_bursting/ABC_Bursting/Data/ABC_output/RNAseq/validation_simulation/model_9/",fileending_2i,".txt")
path_to_plot = string("/project/home17/er4517/project_3/gene_bursting/ABC_Bursting/plots/validation-simulation/model-9/model_9",name,fileending_2i,"_joint_validate.pdf")
a3_2i,b3_2i,c3_2i,d3_2i,e3_2i,f3_2i,di3_2i,w3_2i=read_one_m9(path_to_file_2i,  3, nsamples, 5)

d_2i = hcat(convert(Array{Float64,1}, a3_2i),
            convert(Array{Float64,1}, b3_2i),
            convert(Array{Float64,1}, c3_2i),
            convert(Array{Float64,1}, d3_2i),
            convert(Array{Float64,1}, e3_2i))
a_2i = pan.DataFrame(data= Dict( :c_act=>d_2i[:,1], :c_deact=>d_2i[:,2], :c_deg=>d_2i[:,3], :fb=>d_2i[:,4], :fb_base=>d_2i[:,5]))



### calculate joint approx #####
a3_2i_float =convert(Array{Float64}, a3_2i)
b3_2i_float =convert(Array{Float64}, b3_2i)
c3_2i_float =convert(Array{Float64}, c3_2i)
d3_2i_float =convert(Array{Float64}, d3_2i)
e3_2i_float =convert(Array{Float64}, e3_2i)

a3_2i_float_k = KernelDensity.kde(a3_2i_float)
b3_2i_float_k = KernelDensity.kde(b3_2i_float)
c3_2i_float_k = KernelDensity.kde(c3_2i_float)
d3_2i_float_k = KernelDensity.kde(d3_2i_float)
e3_2i_float_k = KernelDensity.kde(e3_2i_float)

pa = []
pb = []
pc = []
pd = []
pe = []

for i in 1:length(a3_2i)
              p_a3_2i = pdf(a3_2i_float_k, a3_2i[i])
              p_b3_2i = pdf(b3_2i_float_k, b3_2i[i])
              p_c3_2i = pdf(c3_2i_float_k, c3_2i[i])
              p_d3_2i = pdf(d3_2i_float_k, d3_2i[i])
              p_e3_2i = pdf(e3_2i_float_k, e3_2i[i])

              push!(pa, p_a3_2i)
              push!(pb, p_b3_2i)
              push!(pc, p_c3_2i)
              push!(pd, p_d3_2i)
              push!(pe, p_e3_2i)


end
all_a=sum(pa)
all_b=sum(pb)
all_c=sum(pc)
all_d=sum(pd)
all_e=sum(pe)


pa_norm = pa./all_a
pb_norm = pb./all_b
pc_norm = pc./all_c
pd_norm = pd./all_d
pe_norm = pe./all_e

p=[]
for i in 1:length(a3_2i)
              pi = pa_norm[i]*pb_norm[i]* pc_norm[i]* pd_norm[i]* pe_norm[i]
              push!(p,pi)
end
maxe=indmax(p)
###

PyPlot.ion()
fig, ax = PyPlot.subplots(figsize=(15,15),ncols=5, nrows=5)
              left   =  0.125  # the left side of the subplots of the figure
              right  =  0.9    # the right side of the subplots of the figure
              bottom =  0.1    # the bottom of the subplots of the figure
              top    =  0.9    # the top of the subplots of the figure
              wspace =  .5     # the amount of width reserved for blank space between subplots
              hspace =  .5    # the amount of height reserved for white space between subplots
              PyPlot.subplots_adjust(
                 left    =  left,
                 bottom  =  bottom,
                 right   =  right,
                 top     =  top,
                 wspace  =  wspace,
                 hspace  =  hspace
              )
      PyPlot.ioff()
      truth =[-3.,-2.3,-4.,-2.3,2]
      sns.distplot(a3_2i,bins=15, kde= true, hist=true,rug= false ,color = "grey", ax=ax[1,1])
      sns.distplot(b3_2i,bins=15, kde= true, hist=true,rug= false ,   color = "grey", ax=ax[2,2])
      sns.distplot(c3_2i,bins=15, kde= true, hist=true,rug= false ,  color = "grey", ax=ax[3,3])
      sns.distplot(d3_2i,bins=15, kde= true, hist=true,rug= false ,  color = "gray", ax=ax[4,4])
      sns.distplot(e3_2i,bins=15, kde= true, hist=true,rug= false ,   color = "gray", ax=ax[5,5])

      # ax[2,1][:set_xlim]([min(a3_2i...)-0.31,max(a3_2i...)+0.3])
      # ax[2,1][:set_ylim]([min(b3_2i...),max(b3_2i...)])
      # ax[3,1][:set_xlim]([min(a3_2i...)-0.31,max(a3_2i...)+0.3])
      # ax[3,1][:set_ylim]([min(c3_2i...),max(c3_2i...)+0.3])
      # ax[3,2][:set_xlim]([min(b3_2i...)-0.2,max(b3_2i...)+0.2])
      # ax[3,2][:set_ylim]([min(c3_2i...),max(c3_2i...)+0.3])


      sns.jointplot(x="c_act", y="c_deact", data=a_2i, kind="kde",color="gray", ax=ax[2,1])
      sns.jointplot(x="c_act", y="c_deg", data=a_2i, kind="kde", color="grey",ax=ax[3,1])
      sns.jointplot(x="c_act", y="fb", data=a_2i, kind="kde", color="gray",ax=ax[4,1])
      sns.jointplot(x="c_act", y="fb_base", data=a_2i, kind="kde", color="gray",ax=ax[5,1])

      sns.jointplot(x="c_deact", y="c_deg", data=a_2i, kind="kde", color="grey",ax=ax[3,2])
      sns.jointplot(x="c_deact", y="fb", data=a_2i, kind="kde", color="gray",ax=ax[4,2])
      sns.jointplot(x="c_deact", y="fb_base", data=a_2i, kind="kde", color="gray",ax=ax[5,2])

      sns.jointplot(x="c_deg", y="fb", data=a_2i, kind="kde", color="gray",ax=ax[4,3])
      sns.jointplot(x="c_deg", y="fb_base", data=a_2i, kind="kde", color="gray",ax=ax[5,3])
      sns.jointplot(x="fb", y="fb_base", data=a_2i, kind="kde", color="gray",ax=ax[5,4])


          ax[1,1][:set_ylabel]("Activation rate",fontsize=16)
          ax[2,1][:set_ylabel]("Deactivation rate",fontsize=16)
          ax[3,1][:set_ylabel]("Degradation rate",fontsize=16)
          ax[4,1][:set_ylabel]("Baseline",fontsize=16)
          ax[5,1][:set_ylabel]("Feedback k",fontsize=16)
          ax[5,1][:set_xlabel]("Activation rate",fontsize=16)
          ax[5,2][:set_xlabel]("Deactivation rate",fontsize=16)
          ax[5,3][:set_xlabel]("Degradation rate",fontsize=16)
          ax[5,4][:set_xlabel]("Baseline",fontsize=16)
          ax[5,5][:set_xlabel]("Feedback k",fontsize=16)


          ax[1,1][:tick_params](labelsize=12)
          ax[2,2][:tick_params](labelsize=12)
          ax[3,3][:tick_params](labelsize=12)
          ax[4,4][:tick_params](labelsize=12)
          ax[5,5][:tick_params](labelsize=12)
          ax[2,1][:tick_params](labelsize=12)
          ax[3,1][:tick_params](labelsize=12)
          ax[4,1][:tick_params](labelsize=12)
          ax[5,1][:tick_params](labelsize=12)
          ax[3,2][:tick_params](labelsize=12)
          ax[4,2][:tick_params](labelsize=12)
          ax[5,2][:tick_params](labelsize=12)
          ax[4,3][:tick_params](labelsize=12)
          ax[5,3][:tick_params](labelsize=12)
          ax[5,4][:tick_params](labelsize=12)

          ax[1,2][:tick_params](labelsize=12)
          ax[1,3][:tick_params](labelsize=12)
          ax[1,4][:tick_params](labelsize=12)
          ax[1,5][:tick_params](labelsize=12)
          ax[2,3][:tick_params](labelsize=12)
          ax[2,4][:tick_params](labelsize=12)
          ax[2,5][:tick_params](labelsize=12)
          ax[3,4][:tick_params](labelsize=12)
          ax[3,5][:tick_params](labelsize=12)
          ax[4,5][:tick_params](labelsize=12)



      ax[2,1][:scatter]([truth[1]], [truth[2]],color ="gold", marker = "x", s =200, zorder =120)
      ax[3,1][:scatter]([truth[1]], [truth[3]],color ="gold", marker = "x", s =200, zorder =120)
      ax[4,1][:scatter]([truth[1]], [truth[4]],color ="gold", marker = "x", s =200, zorder =120)
      ax[5,1][:scatter]([truth[1]], [truth[5]],color ="gold", marker = "x", s =200, zorder =120)

      ax[3,2][:scatter]([truth[2]], [truth[3]],color ="gold", marker = "x", s =200, zorder =120)
      ax[4,2][:scatter]([truth[2]], [truth[4]],color ="gold", marker = "x", s =200, zorder =120)
      ax[5,2][:scatter]([truth[2]], [truth[5]],color ="gold", marker = "x", s =200, zorder =120)

      ax[4,3][:scatter]([truth[3]], [truth[4]],color ="gold", marker = "x", s =200, zorder =120)
      ax[5,3][:scatter]([truth[3]], [truth[5]],color ="gold", marker = "x", s =200, zorder =120)

      ax[5,4][:scatter]([truth[4]], [truth[5]],color ="gold", marker = "x", s =200, zorder =120)

      ax[1,2][:axis]("off")
      ax[1,3][:axis]("off")
      ax[1,4][:axis]("off")
      ax[1,5][:axis]("off")


      ax[2,3][:axis]("off")
      ax[2,4][:axis]("off")
      ax[2,5][:axis]("off")

      ax[3,4][:axis]("off")
      ax[3,5][:axis]("off")

      ax[4,5][:axis]("off")

      ax[1,1][:axvline]([truth[1]],color ="gold",label = "true value")
     ax[2,2][:axvline]([truth[2]],color ="gold")
     ax[3,3][:axvline]([truth[3]],color ="gold")
     ax[4,4][:axvline]([truth[4]],color ="gold")
     ax[5,5][:axvline]([truth[5]],color ="gold")


     ax[1,1][:axvline](a3_2i[maxe],color ="purple",label = "max. joint probability")
     ax[2,2][:axvline](b3_2i[maxe],color ="purple")
     ax[3,3][:axvline](c3_2i[maxe],color ="purple")
     ax[4,4][:axvline](d3_2i[maxe],color ="purple")
     ax[5,5][:axvline](e3_2i[maxe],color ="purple")

     # ax[1,1][:axvline](a3_2i[indmin(di3_2i)],color ="green")
     # ax[2,2][:axvline](b3_2i[indmin(di3_2i)],color ="green")
     # ax[3,3][:axvline](c3_2i[indmin(di3_2i)],color ="green")
     # ax[4,4][:axvline](d3_2i[indmin(di3_2i)],color ="green")
     # ax[5,5][:axvline](e3_2i[indmin(di3_2i)],color ="green")
     #
     #
     # ax[1,1][:axvline](mean(a3_2i),color ="pink")
     # ax[2,2][:axvline](mean(b3_2i),color ="pink")
     # ax[3,3][:axvline](mean(c3_2i),color ="pink")
     # ax[4,4][:axvline](mean(d3_2i),color ="pink")
     # ax[5,5][:axvline](mean(e3_2i),color ="pink")
     ax[1,1][:legend](fontsize = 16, bbox_to_anchor=(1.05, 1), loc=2, borderaxespad=1.8)

          # ax[1,5][:annotate]("gold: truth",xy=(.1,.1), xytext= (.2,.4),color="gold", fontsize = 16,zorder=100)
          # ax[1,5][:annotate]("purple: max joint ",xy=(.1,.1), xytext= (.2,.6),color="purple", fontsize = 16,zorder=100)
          # ax[1,5][:annotate]("green:min distance",xy=(.1,.1), xytext= (.2,.8),color="green", fontsize = 16,zorder=100)
          # # ax[1,5][:annotate]("pink: mean marginal",xy=(.1,.1), xytext= (.2,.2),color="pink", fontsize = 16,zorder=100)
          # ax[1,5][:tick_params](color="white",labelsize=1)
          # ax[1,5][:spines]["top"][:set_color]("none")
          # ax[1,5][:spines]["right"][:set_color]("none")
          # ax[1,5][:spines]["left"][:set_color]("none")
          # ax[1,5][:spines]["bottom"][:set_color]("none")
# axarr[0,0].axis('off')

 # PyPlot.savefig(path_to_plot)
