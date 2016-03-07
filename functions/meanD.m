function [ theta, rho ] = meanD( thetas )
%meanD calculates the mean direction and dispersion of 2D data
% pass thetas a vector of observed directions (radians)
% return theta - mean tendency and rho - a value from 0:n representing
% dispersion
R= sum([cos(thetas)', sin(thetas)']) ;
n=length(thetas);
rho=(n-sqrt(sum(R.^2)))/n;
theta=atan2(R(2),R(1));


end

