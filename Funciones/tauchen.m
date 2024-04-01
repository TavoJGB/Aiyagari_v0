function [Z,Zprob] = tauchen(N,mu,rho,sigma,m)
%Function TAUCHEN
%
%Purpose:    Finds a Markov chain whose sample paths
%            approximate those of the AR(1) process
%                z(t+1) = (1-rho)*mu + rho * z(t) + eps(t+1)
%            where eps are normal with stddev sigma
%
%Format:     {Z, Zprob} = Tauchen(N,mu,rho,sigma,m)
%
%Input:      N       scalar, number of nodes for Z
%            mu      scalar, unconditional mean of process
%            rho     scalar
%            sigma   scalar, std. dev. of epsilons
%            m       max +- std. devs.
%
%Output:     Z       N*1 vector, nodes for Z
%            Zprob   N*N matrix, transition probabilities
%
%    Martin Floden
%    Fall 1996
%
%    This procedure is an implementation of George Tauchen's algorithm
%    described in Ec. Letters 20 (1986) 177-181.
%


Z     = zeros(N,1);
Zprob = zeros(N,N);
a     = (1-rho)*mu;

Z(N)  = m * sqrt(sigma^2 / (1 - rho^2));
Z(1)  = -Z(N);
zstep = (Z(N) - Z(1)) / (N - 1); %distance between points in the grid for z

for i=2:(N-1)
    Z(i) = Z(1) + zstep * (i - 1); %we create a grid
end 

Z = Z + a / (1-rho);

for j = 1:N
    for k = 1:N

        if k == 1
            Zprob(j,k) = normcdf((Z(1) - a - rho * Z(j) + zstep / 2) / sigma,0,1);
        elseif k == N
            Zprob(j,k) = 1 - normcdf((Z(N) - a - rho * Z(j) - zstep / 2) / sigma,0,1);
        else
            Zprob(j,k) = normcdf((Z(k) - a - rho * Z(j) + zstep / 2) / sigma,0,1) - ...
                         normcdf((Z(k) - a - rho * Z(j) - zstep / 2) / sigma,0,1);
        end



        
    end
end


