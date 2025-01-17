#testing for basic understanding

using ABC_Bursting, DifferentialEquations

base_model = @reaction_network CC begin
          c1, G0 --> G1
          c2, G1 --> G0
          c3, G1 --> G1 + P
          c4, P --> 0
end c1 c2 c3 c4
function data_scaling_RNAseq(outcome::Array{Int64}, parameter::Float64)
    output = log10.((outcome[3] * parameter).+1)
    return output
end
#act,de-act,deg
slow = [3.2,1.2,2.1,1.3,1.8,1.]

parameter_input = slow
n_samples=200


#Define starting state
c1 = 10^parameter_input[1]  #Activation
c2 = 10^parameter_input[2]  #Deactivation
c3 = 1.0                    #Expression
c4 = 10^parameter_input[3]  #Degradation
c5 = 10^parameter_input[4]     #Feedback baseline
k = 10^parameter_input[5]     #Feedback k
c6 = parameter_input[6]     #Scale factor


#Define starting state at stationary distribution

G = 2

P =(
          (
                    sqrt(4*c1*c3*c4*G*k*(c1+c2+c5)+(c1*c4*k-c1*c3*G+c2*c4*k)^2)
                    +
                    (c1*c3*G-c1*c4*k-c2*c4*k)
          )
          /
          (2*c4*(c1+c2+c5))
)

G1 = round(Int64,(

(c1*G*(k+P))
/
(c1*(k+P)+c2*(k+P)+c5*P)
))

P = round(Int64,(P))
if P < 0
          P = 0
else
          P = P
end

if G1 < 0
          G1 = 0
else
          G1 = G1
end
G0 = 2 - G1
starting_state = [G0,G1,P]
time = 40000.0
time_range= (0.0,time)
#Define model
#Set rate parameters
rate1 = function (u,p,t)
          (c1)*u[1]
end

affect! = function (integrator)
          integrator.u[1] -= 1
          integrator.u[2] += 1
end
jump1 = DifferentialEquations.ConstantRateJump(rate1,affect!)

rate2 = function (u,p,t)
          return (c2*u[2])+(u[2]*c5*((u[3]/k)/(1+(u[3]/k))))
end

affect! = function (integrator)
          integrator.u[1] += 1
          integrator.u[2] -= 1
end
jump2 = DifferentialEquations.ConstantRateJump(rate2,affect!)

rate3 = function (u,p,t)
          return (c3)*u[2]
 end
affect! = function (integrator)
          integrator.u[2] += 0
          integrator.u[3] += 1
end
jump3 = DifferentialEquations.ConstantRateJump(rate3,affect!)

rate4 = function (u,p,t)
          return (c4)*u[3]
end
affect! = function (integrator)
          integrator.u[3] -= 1
end
jump4 = DifferentialEquations.ConstantRateJump(rate4,affect!)

prob = DifferentialEquations.DiscreteProblem(starting_state,time_range)
jump_prob = DifferentialEquations.JumpProblem(prob,DifferentialEquations.Direct(),jump1,jump2,jump3,jump4)

#Simulate multiple cells and take end point
distribution_data = Array{Float64}(n_samples)
sol = DifferentialEquations.solve(jump_prob,DifferentialEquations.FunctionMap())
max_time = sol.t[end]
for i in 1:n_samples
          outcome = round.(Int64,(sol(i*(max_time/(n_samples+1)))))
          distribution_data[i,1] = data_scaling_RNAseq(outcome, c6)
end


r=range(1,n_samples)
using Plots

b=plot(sol,xlab="time",ylab="product abundance", title="slow: sol of jumpproblem")

a=plot(r,distribution_data,title ="slow: product abundance of 100 cells/timepoints converted by scaling factor",xlab="cell/timepoint",ylab="product abundance",label =["P"])
title =string("simulated product abundance of ", n_samples," cells")
# savefig(a,"slowa.png")
# savefig(b,"slowb.png")
histogram(distribution_data,label=["fast product abundance"],title=title, xlab="product abundance", ylab = "frequency",nbins=20)
