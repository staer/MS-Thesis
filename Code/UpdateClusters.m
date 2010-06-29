function clusters = UpdateClusters(regionX, regionY, regionWidth, regionHeight, clusters)
% Things to store for a cluster...
%  1.) X-coord      regionX
%  2.) Y-coord      regionY
%  3.) Width        regionWidth
%  4.) Height       regionHeight
%  5.) Is active?
%  6.) active count
STARTING_VALUE = 3;

clusters{size(clusters,2)+1} = {regionX,regionY,regionWidth,regionHeight,1,STARTING_VALUE};
