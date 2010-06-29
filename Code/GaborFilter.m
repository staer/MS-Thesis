function filter = GaborFilter(filterSize, theta, sigma, lambda)
% GaborFilter.m
%
% Creates a gabor filter based on the following equation
%
% G(x,y) = exp(-((X^2+g^2Y^2)/(2*sigma^2)) * cos((2*pi/lamba)*X)
% where X = x*cos(theta) + y*sin(theta) 
% and Y = -x*sin(theta) + y*cos(theta)
%
% g (or gamma) is the aspect ratio, defined as 0.3
%
% The parameters for filter size, sigma, lamba and orientation can be
% the following, as described by Serre et al.
% Size      Sigma       Lamba
%   7       2.8         3.5
%   9       3.6         4.6
%   11      4.5         5.6
%   13      5.4         6.8
%   15      6.3         7.9
%   17      7.3         9.1
%   19      8.2         10.3
%   21      9.2         11.5
%   23      10.2        12.7
%   25      11.3        14.1
%   27      12.3        15.4
%   29      13.4        16.8
%   31      14.6        18.2
%   33      15.8        19.7
%   35      17.0        21.2
%   37      18.2        22.8
%
% Recomended values of theta are 0, 45, 90, and 135 degrees
%
% Source for parameters and equation:
% T. Serre, L. Wolf, T. Poggio, "Object Recognition with Features Inspired
% by Visual Cortex" Center for Biological and Computational Learning,
% McGovern Institute and Brain and Cognitive Sciences Department,
% Massachusetts Institute of Technology

filter = zeros(filterSize,filterSize);
row = 1;
col = 1;
for y=-floor(filterSize/2):1:floor(filterSize/2)
    for x=-floor(filterSize/2):1:floor(filterSize/2)
        
        X = x*cosd(theta) + y*sind(theta);
        Y = -x*sind(theta) + y*cosd(theta);
       
        X2 = X^2;
        Y2 = Y^2;
        sigma2 = sigma^2;
        gammaOld = .3;
        gamma2 = gammaOld^2;
       
        G = exp(-((X2+gamma2*Y2)/(2*sigma2)))*cosd(((2*pi)/lambda)*X);
        filter(row,col) = G;
  
        col = col + 1;
    end
    col = 1;
    row = row + 1;
end

% Normalize so that the mean is zero 
% Normalize so taht the sum of the squares is 1
% Idea from "Multiclass Object Recognition with Sparse, Localized Features"
% by J. Mutch and D. Lowe
m = mean(filter(:));
filter = filter - m;

filter2 = filter .* filter;
s = sum(filter2(:));
filter = filter ./ sqrt(s);