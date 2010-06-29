function [ulX, ulY, width,  height, newclusters] = CheckClusters(clusters)
% Update the short-term memory of recently seen "clusters", or attended
% regions. Only keep regions in memory for a short period of time before
% forgetting about them.

CUTOFF_THRESHOLD = -60;  % number of frames past 0 to inhibit the region!
ulX = -1;
ulY = -1;
width = -1;
height = -1;
newclusters = {};

% Loop through each cluster and attempt to find a "match"
for i=1:size(clusters,2)
    clusters{i}{6}  = clusters{i}{6} - 1;
    if(clusters{i}{6} > 0)
        ulX = clusters{i}{1};
        ulY = clusters{i}{2};
        width = clusters{i}{3};
        height = clusters{i}{4};
    end
    
    % only add "active" clusters! 
    % "active" is simply if they are still above the cutoff threshold
    if(clusters{i}{6} > CUTOFF_THRESHOLD)
        newclusters{size(newclusters,2)+1} = {clusters{i}{1},clusters{i}{2},clusters{i}{3},clusters{i}{4},clusters{i}{5},clusters{i}{6}};
    else
        fprintf(1,'\nREMOVING DEAD CLUSTER!\n');
    end
end


