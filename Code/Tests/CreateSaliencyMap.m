function sMap = CreateSaliencyMap(imagePath)
% CreateSaliencyMap.m
%
% Create a saliency map given an image path

% Read in the image and convert it to grayscale (intensity)
image = mat2gray(imread(imagePath));

image = imresize(image, [NaN 320]);
figure, imshow(image), title('Original Image');

[dogFilters, gFilters] = CreateFilters();
[intensityContrastMap, orientationMap, colorDifferenceMap] = GetSaliencyMapStillComponents(image, dogFilters, gFilters);


intensityContrastMap = Inhibit(intensityContrastMap);
orientationMap = Inhibit(orientationMap);
colorDifferenceMap = Inhibit(colorDifferenceMap);

% Combine the 3 maps into a saliency map!
sMap = intensityContrastMap + orientationMap + colorDifferenceMap;
sMap = sMap ./ (max(sMap(:))+eps);

figure, imshow(sMap), title('Saliency Map'), colormap('hot'), colorbar;

centers = FindSalientCenters(sMap);

image = DrawBoundingBoxes2(image,centers);

figure, imshow(image), title('Salient Regions');
