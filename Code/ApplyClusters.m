function [map] = ApplyClusters(clusters, inhibitionMap)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                   %
% Given a list of clusters and an inhibition map,   %
% apply all the clusters to the inhibition map and  %
% return the new "clamped" inhibition map. To apply %
% a cluster, each active cluster that needs         %
% inhibiton (activeCount < 0) gets a inverse DoG    %
% filter applied to it so everything in the region  %
% is inhibited and the surrounding region is        %
% minorly excited.                                  %
%                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Things to store for a cluster...
%  1.) X-coord      regionX
%  2.) Y-coord      regionY
%  3.) Width        regionWidth
%  4.) Height       regionHeight
%  5.) Is active?   NOTE: Currently not in use!
%  6.) active count

% Loop through each cluster and attempt to find a "match"
for i=1:size(clusters,2)
    if(clusters{i}{6} <= 0)
        value = abs(clusters{i}{6});
        ulX = clusters{i}{1};
        ulY = clusters{i}{2};
        width = clusters{i}{3};
        height = clusters{i}{4};
       
        if(width>2)
            scale = 1.0 - (value / 60.0);

            % Create a new DoG filter to inhibit the region, make it "extra"
            % wide so that the surrounding area is excited and the interior is
            % inhibited.
            newWidth = width;% * 3;
            sigmaEx = .416666 * newWidth;
            sigmaInh = .125 * newWidth;
            region = DoGFilter2(newWidth,sigmaEx,sigmaInh,3.5,1.5);
            region = region - region(1,1);
            region = region ./ abs(min(region(:)));
            region(find(region>0)) = region(find(region>0))*.05;

            % scale the region based on the clusters "life"
            region = region .* scale;

            startY = ulY;%
            endY = ulY + height - 1;% 
            startX = ulX;%
            endX = ulX + width - 1;%

            inhibitionMap(startY:endY,startX:endX) = inhibitionMap(startY:endY,startX:endX) + region;
        end
    end
end

% Clamp the values of the inhibition map!
inhibitionMap(find(inhibitionMap<0)) = 0;
inhibitionMap(find(inhibitionMap>1.2)) = 1.2;

map = inhibitionMap;

