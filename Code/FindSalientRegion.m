function [ulX ulY width height] = FindSalientRegion(input)
% finds the most salient region given an input saliency map

% Constants
dSize = floor(size(input,2)*.15);  
TRESHHOLD_VALUE = 0.4;%
EXPAND_VALUE = 1.0;
MINIMUM_REGION_SIZE = floor(dSize);

% Find the maximum saliency in the image and threshold the rest accordingly
[i j] = find(input==max(input(:)),1);
saliency = input(i,j);
threshold = saliency * TRESHHOLD_VALUE;
tInput = input >= threshold;

% Perform an image close to get rid of "small" regions
se = strel('disk',dSize); 
tInput = imclose(tInput,se);

% Label the image and get stats for each area
[L num] = bwlabel(tInput);

stats = regionprops(L,'Area','BoundingBox');

lSaliency = 0;
lX = 0;
lY = 0;
lWidth = 0;
lHeight = 0;

for i=1:num
    tX = stats(i).BoundingBox(1);
    tY = stats(i).BoundingBox(2);
    tW = stats(i).BoundingBox(3);
    tH = stats(i).BoundingBox(4);
   
    % Get the average saliency per region and take that
    top = floor(tY+1);
    bottom = floor(tY + tH);
    left = floor(tX+1);
    right = floor(tX+tW);
    area = floor(tW*tH);
    avgSaliency = sum(sum(input(top:bottom, left:right))) / area;
    
    % Check to see if the region has the highest average saliency and the
    % region is big enough! (20)
    if (avgSaliency > lSaliency && area > MINIMUM_REGION_SIZE)
        lSaliency = avgSaliency;
        lX = stats(i).BoundingBox(1);
        lY = stats(i).BoundingBox(2);
        lWidth = stats(i).BoundingBox(3);
        lHeight = stats(i).BoundingBox(4);
    end
end

% Extract a little "extra" from each region
lWidthPad = floor(lWidth * EXPAND_VALUE);
lHeightPad = floor(lHeight * EXPAND_VALUE);

lWidth = lWidth + 2*lWidthPad;
lHeight = lHeight + 2*lHeightPad;

% make the region a box (for DoG inhibition)
% recenter as well
if lWidth < lHeight
    d = lHeight - lWidth;
    lX = lX - floor(d/2);
    lWidth = lHeight;
end

if lHeight < lWidth
    d = lWidth - lHeight;
    lY = lY - floor(d/2);
    lHeight = lWidth;
end

% Make sure that the regions never go "out of bounds"
lX = lX -  lWidthPad;
if lX < 1
    lX = 1;
end

lY = lY - lHeightPad;
if lY < 1
    lY = 1;
end

if lX + lWidth > size(input,2)
    lWidth = floor(size(input,2) - lX);
end

if lY + lHeight > size(input, 1)
    lHeight = floor(size(input,1) - lY);
end

% Set return values
ulY = floor(lY);
ulX = floor(lX);

width = lWidth;
height = lHeight;

if width < 2
    width = 2;
end

if height < 2
    height = 2;
end

if width<height
    height = width;
end

if height<width
    width = height;
end






