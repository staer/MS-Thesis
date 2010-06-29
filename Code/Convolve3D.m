function [result] = Convolve3D(A, B)
% Perform a 3D convolution of A with B
% Note: this is not a true 3D convolution. It is just the sum of many 2D
% convolutions.

result = zeros(size(A,1),size(A,2));
for i=1:size(A,3)
    result = result + conv2(A(:,:,i),B(:,:,i),'same');    
end