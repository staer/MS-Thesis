function filter = DoGFilter2(filterSize, sigmaEx, sigmaInh, cEx, cInh)
% filterSize - EVEN only
% Alternate way of creating a DoG filter, uses different parameters for
% more control than other DoG filter.
 
[x,y] = meshgrid(-1*(filterSize/2-1):filterSize/2 -1*(filterSize/2-1):filterSize/2);
 
% First Gaussian
exp1 = exp( -1*( x .* x + y .* y)./(2*sigmaEx*sigmaEx));
FirstTerm = ((cEx*cEx)/(2*pi*sigmaEx*sigmaEx))*exp1;  

% Second Gaussian
exp2 = exp( -1*( x .* x + y .* y)./(2*sigmaInh*sigmaInh));
SecondTerm = ((cInh*cInh)/(2*pi*sigmaInh*sigmaInh))*exp2;

% Take the difference
filter = (FirstTerm - SecondTerm);