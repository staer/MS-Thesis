function [result] = Inhibit(inp)
% Perform lateral inhibition (local competition) on a given input
% Do single pass only for speed

s = size(inp,2)/4;

sigmaEx = s * 0.02;
sigmaInh = s * 0.25;
cEx = .5;
cInh = 1.5;
filter = DoGFilter2(s,sigmaEx,sigmaInh,cEx,cInh);
filter = filter; + abs(0.15*min(filter(:)));

out = inp + imfilter(inp,filter,'symmetric');% 
out(find(out<0)) = 0;

result = out;
