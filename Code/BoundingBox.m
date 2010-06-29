function [output] = BoundingBox(image, ulX, ulY, width, height)
% Draw a bounding box on a color image
% 
% ulX, ulY are the upper-left coordinates
% width/height are the width and height

ux = ulX;
bx = ulX + width;
uy = ulY;
by = ulY + height;
    
image(uy,ux:bx,1) = 1;
image(uy,ux:bx,2) = 0;
image(uy,ux:bx,3) = 0;

image(by,ux:bx,1) = 1;
image(by,ux:bx,2) = 0;
image(by,ux:bx,3) = 0;

image(uy:by,ux,1) = 1;
image(uy:by,ux,2) = 0;
image(uy:by,ux,3) = 0;

image(uy:by,bx,1) = 1;
image(uy:by,bx,2) = 0;
image(uy:by,bx,3) = 0;
    
output = image;