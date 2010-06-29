function [intensityContrastMap, orientationMap, colorDifferenceMap] = GetSaliencyMapStillComponents(image, dogFilters, gFilters)
% Get the intensity, orientation, and color difference maps from a single
% frame

% Create a saliency map given an image path

% Create arrays of all our intermediate feature maps
cImages = cell(3,1);   % 3 contrast maps
oImages = cell(36,1);  % 36 orientation maps

% Read in the image and convert it to grayscale (intensity)
rgbImage = mat2gray(image);

grayImage = (rgbImage(:,:,1) + rgbImage(:,:,2) + rgbImage(:,:,3)) ./ 3;

% Find the maximum values of each filter
maxDOGFilters1 = sum(dogFilters{1}(find(dogFilters{1}>0)));
maxDOGFilters2 = sum(dogFilters{2}(find(dogFilters{2}>0)));
maxDOGFilters3 = sum(dogFilters{3}(find(dogFilters{3}>0)));

maxDOGFilters1a = sum(dogFilters{1}(find(dogFilters{1}<0)));
maxDOGFilters2a = sum(dogFilters{2}(find(dogFilters{2}<0)));
maxDOGFilters3a = sum(dogFilters{3}(find(dogFilters{3}<0)));

if(abs(maxDOGFilters1a) > maxDOGFilters1)
    maxDOGFilters1 = abs(maxDOGFilters1a);
end

if(abs(maxDOGFilters2a) > maxDOGFilters2)
    maxDOGFilters2 = abs(maxDOGFilters2a);
end

if(abs(maxDOGFilters3a) > maxDOGFilters3)
    maxDOGFilters3 = abs(maxDOGFilters3a);
end

cImages{1} = abs(imfilter(grayImage,dogFilters{1},'symmetric'));
cImages{2} = abs(imfilter(grayImage,dogFilters{2},'symmetric'));
cImages{3} = abs(imfilter(grayImage,dogFilters{3},'symmetric'));

% Scale to the same dynamic range
cImages{1} = cImages{1} ./ maxDOGFilters1;
cImages{2} = cImages{2} ./ maxDOGFilters2;
cImages{3} = cImages{3} ./ maxDOGFilters3;

% For each contrast image size...
for contrastSize=1:3
    
    % For each Gabor filter size...
    for gaborSize=1:3
        % For each Gabor orientation...
        for gaborOrientation=1:4
            
            % Calculate one of the 36 orientation feature maps
            cImage = cImages{contrastSize};
            gfilter = gFilters{gaborSize, gaborOrientation};
            map = abs(imfilter(cImage,gfilter,'symmetric'));
            m = sum(gfilter(find(gfilter>0)));
            m1 = sum(gfilter(find(gfilter<0)));
            if(abs(m1)>m)
                m = m1;
            end
            map = map ./ m;
            
            oImages{(contrastSize-1)*12+(gaborSize-1)*4+(gaborOrientation-1)+1} = map;
        end
    end
    
end

% Color channels - Decouple Hue from Intensity
% r = r / I
% g = g / I
% b = b / I
r = rgbImage(:,:,1) ./ (grayImage+eps);
g = rgbImage(:,:,2) ./ (grayImage+eps);
b = rgbImage(:,:,3) ./ (grayImage+eps);

% Normalize (max 3)
r = r ./ 3.0;
g = g ./ 3.0;
b = b ./ 3.0;

% Create 4 color channels
R = r-((g+b)./2.0);
G = g-((r+b)./2.0);
B = b-((r+g)./2.0);
Y = r+g-(2*(abs(r-g) + b));

% Normalize R/G/B/Y
Y = Y ./ 2.0;


% Create R-G and B-Y maps
RG = R-G;
BY = B-Y;

colorRG8 = abs(imfilter(RG,dogFilters{1},'symmetric'));
colorRG16 = abs(imfilter(RG,dogFilters{2},'symmetric'));
colorRG32 = abs(imfilter(RG,dogFilters{3},'symmetric'));

colorBY8 = abs(imfilter(BY,dogFilters{1},'symmetric'));
colorBY16 = abs(imfilter(BY,dogFilters{2},'symmetric'));
colorBY32 = abs(imfilter(BY,dogFilters{3},'symmetric'));

colorRG8 = colorRG8 ./ maxDOGFilters1;
colorRG16 = colorRG16 ./ maxDOGFilters2;
colorRG32 = colorRG32 ./ maxDOGFilters3;
colorBY8 = colorBY8 ./ maxDOGFilters1;
colorBY16 = colorBY16 ./ maxDOGFilters2;
colorBY32 = colorBY32 ./ maxDOGFilters3;

% Combine maps to make intensity/orientation/color maps
intensityContrastMap = cImages{1} + cImages{2} + cImages{3};
intensityContrastMap = intensityContrastMap ./ (max(intensityContrastMap(:))+eps);

orientationMap = oImages{1};
for i=2:36
    orientationMap = orientationMap + oImages{i};
end
orientationMap = orientationMap ./ (max(orientationMap(:))+eps);

colorDifferenceMap = colorRG8 + colorRG16 + colorRG32 + colorBY8 + colorBY16 + colorBY32;
colorDifferenceMap = colorDifferenceMap ./ (max(colorDifferenceMap(:))+eps);


