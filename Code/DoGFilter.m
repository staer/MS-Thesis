function filter = DoGFilter(filterSize, sigmaex, sigmainh, firstTerm, secondTerm, filterScale)
% filterSize - EVEN only
% Based on Dr. Roger Gaborski's Code

% Examples...
% DoG8 = DoGFilter(8,.04,.16, 6.0, 1.0, .41);
% DoG16 = DoGFilter(16,.05,.15,6.5,1.0,.23);
% DoG32 = DoGFilter(32,.05,.15,7.0,1.0,.41);
 
Sigmaex = sigmaex*filterSize;
Sigmainh = sigmainh*filterSize;
[x,y] = meshgrid(-1*(filterSize/2-1):filterSize/2 -1*(filterSize/2-1):filterSize/2);
 
% First Gaussian
exp1 = exp( -1*( x .* x + y .* y)./(2*Sigmaex*Sigmaex));
FirstTerm = firstTerm*exp1;  

% Second Gaussian
exp2 = exp( -1*( x .* x + y .* y)./(2*Sigmainh*Sigmainh));
SecondTerm = secondTerm*exp2;

% Take the difference
filter = filterScale*(FirstTerm - SecondTerm);
 