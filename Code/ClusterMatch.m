function match = ClusterMatch(cluster,regionX, regionY, regionWidth, regionHeight)
% Check to see if cluster has a match (both specified in params). Return 1
% if match, 0 if no match. This method is currently deprecated and not in
% use.

% Start with a match being found
match = 1;

% Calculate centers
centerX = regionX + floor(regionWidth/2);
centerY = regionY + floor(regionHeight/2);

clusterX = cluster{1} + floor(cluster{3}/2);
clusterY = cluster{2} + floor(cluster{4}/2);
clusterWidth = cluster{3};
clusterHeight = cluster{4};

% calculate "wiggle room"
wiggleX = ceil(regionWidth*0.2);
wiggleY = ceil(regionHeight*0.2);

fprintf(1,'\nChecking (%i,%i) vs (%i,%i)...',centerX,centerY,clusterX,clusterY);

% check how similar the center is....
if (centerX < (clusterX-wiggleX)) || (centerX > (clusterX+wiggleX))
    match = 0;
elseif (centerY < (clusterY-wiggleY)) || (centerY > (clusterY+wiggleY))
    match = 0;
else
        
end


