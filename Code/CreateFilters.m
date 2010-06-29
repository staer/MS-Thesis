function [dogFilters, gFilters, blinkFilter, dFilters] = CreateFilters()
% Create a variety of filters used by the model

% DIFFERENCE OF GAUSSIAN FILTERS
fprintf(1,'Creating DoG Filters...');
dogFilters = cell(3,1);
dogFilters{1} = DoGFilter(8,.04,.16, 6.0, 1.0, .41);
dogFilters{2} = DoGFilter(16,.05,.15, 6.5, 1.0, .23);
dogFilters{3} = DoGFilter(32,.05,.15, 7.0, 1.0, .06);
fprintf(1,'Complete!\n');

% GABOR FILTERS
fprintf(1,'Creating Gabor Filters...');
gFilters = cell(3,4);
gFilters{1,1} = GaborFilter(7,0,2.8,3.5);
gFilters{1,2} = GaborFilter(7,45,2.8,3.5);
gFilters{1,3} = GaborFilter(7,90,2.8,3.5);
gFilters{1,4} = GaborFilter(7,135,2.8,3.5);
gFilters{2,1} = GaborFilter(15,0,6.3,7.9);
gFilters{2,2} = GaborFilter(15,45,6.3,7.9);
gFilters{2,3} = GaborFilter(15,90,6.3,7.9);
gFilters{2,4} = GaborFilter(15,135,6.3,7.9);
gFilters{3,1} = GaborFilter(31,0,14.6,18.2);
gFilters{3,2} = GaborFilter(31,45,14.6,18.2);
gFilters{3,3} = GaborFilter(31,90,14.6,18.2);
gFilters{3,4} = GaborFilter(31,135,14.6,18.2);
fprintf(1,'Complete!\n');

% BLINK FILTER
fprintf(1,'Creating Blink Filter...');
blinkFilter = CreateGDFilter(15,1,0,0,0,0,90,90,1.0,1.0,1.0,1/(sqrt(2*pi)));
fprintf(1,'Complete!\n');

% DIRECTIONAL FILTERS
fprintf(1,'Creating Directional Filters...');
dFilters = cell(4,1);
dFilters{1} = CreateGDFilter(15,1,0,0,0,0,0,45,1.0,1.0,1.0,1/(sqrt(2*pi)));
dFilters{2} = CreateGDFilter(15,1,0,0,0,0,45,45,1.0,1.0,1.0,1/(sqrt(2*pi)));
dFilters{3} = CreateGDFilter(15,1,0,0,0,0,90,45,1.0,1.0,1.0,1/(sqrt(2*pi)));
dFilters{4} = CreateGDFilter(15,1,0,0,0,0,135,45,1.0,1.0,1.0,1/(sqrt(2*pi)));
fprintf(1,'Complete!\n');