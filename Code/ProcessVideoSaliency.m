function [] = ProcessVideoSaliency(inputFile)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                   %
% Clean up the output from previous runs            %
%                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
delete('BoundingBoxOutput.txt');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                   %
% These are variables which can be changed in order %
% to toggle what type of output is rendered from    %
% the program.                                      %
%                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
showSaliencyOutput = 0;
showBoxedOutput = 1;
showExtractedOutput = 1;
showFrameOutput = 1;
showInhibitionOutput = 0;
showPositionOutput = 1;
testingOutput = 0;          % This is intermediate figures rendered for
                            % testing purposes. If this is set to "1" be
                            % prepared for alot of figures!
                            
resampleData = 1;           % If this is set, resample the input data to be 320x240 then scale it back up afterwards
                            % this is to drastically improve speed on
                            % larger images.
                            


                                  
% Current Salient Regions... values of -1 means that there is no currently
% attended region and the program should find one!
ulX = -1;
ulY = -1;
width = -1;
height = -1;

totalTimeElapsed = 0;
motionBuffer = 0;    % 0 is used for uninitialized

% This value is how many frames we should "stick" to each region
% Biologically speaking shifts occur about every 50ms or about every
% 2 frames in a 30 FPS video. Increasing the number will DRASTICALLY
% increase processing speed!
STARTING_CLUSTER_LIFE = 3;  

% COEFFICIENTS used for appropriate shifting
CONTRAST_COEFFICIENT = 1.0;
ORIENTATION_COEFFICIENT = 1.0;
COLOR_COEFFICIENT = 1.0;
MOTION_COEFFICIENT = 1.0;


% Create the filter's that will be used for the whole program
[dogFilters, gFilters, blinkFilter, dFilters] = CreateFilters();

% Get some information about the movie
fileinfo = aviinfo(inputFile);
frameWidth = fileinfo.Width;
frameHeight = fileinfo.Height;

startFrame = 30; 
endFrame = startFrame+90;    % due to filtering we can't process the 
                                  % entire video. We need to be able to 
                                  % look approx. 35 frames into the future.

aspectRatio = 1;
resizedFrame = 0;
blinkBuffer = 0;

if(resampleData==1)
   oldW = frameWidth;
   oldH = frameHeight;
   aspectRatio = oldW / 320.0;
   frameWidth = 320;
   frameHeight = floor(oldH / aspectRatio);
   
   fprintf(1,'Resampling Enabled! (%ix%i => 320x%i)\n',oldW,oldH,frameHeight);
   fprintf(1,'Aspect Ratio = %f\n\n',aspectRatio);
end

inhibitionMap = ones(frameHeight,frameWidth);



% Create an empty list of clusters
clusters = {};

% Process each from at a time
for currFrame=startFrame:endFrame 

    fprintf(1,'**==> Processing Frame %i of %i...',currFrame,endFrame);
    
    % Read in the current frame for processing
    mov = aviread(inputFile,currFrame); 
    frameRGB = mat2gray(im2double(mov(1,1).cdata));
    
    
    frameRGBOriginal = frameRGB;
    if(resampleData==1)
        frameRGB = imresize(frameRGB,[frameHeight frameWidth]);
        resizedFrame = frameRGB;
    end
    
    % Smooth the frame to get rid of camera artifacts
    w = fspecial('gaussian', 15);
    smoothedFrame = imfilter(frameRGB, w, 'conv', 'replicate');
    
    % Update our current clusters, see if we need a new one!
    [ulX, ulY, width, height, clusters] = CheckClusters(clusters);
    
    
    
    % if there is no active cluster find a new one!
    if(ulX == -1 && ulY == -1 && width == -1 && height == -1)
        
        % Compute the still saliency components
        [intensityContrastMap, orientationMap, colorDifferenceMap] = GetSaliencyMapStillComponents(smoothedFrame, dogFilters, gFilters);

        % Compute the motion saliency components
        [motionMap, motionBuffer] = GetSaliencyMapMotionComponents(inputFile, currFrame, blinkFilter, dFilters, resampleData, motionBuffer);
        
        
        tic;
        sMap = intensityContrastMap + orientationMap + colorDifferenceMap + motionMap;
        sMap = sMap ./ 4.0;
        
        % Inhibit each map individually
        intensityContrastMap = Inhibit(intensityContrastMap);
        orientationMap = Inhibit(orientationMap);
        colorDifferenceMap = Inhibit(colorDifferenceMap);
        motionMap = Inhibit(motionMap);
      
        sMap = (CONTRAST_COEFFICIENT .* intensityContrastMap);
        sMap = sMap + (ORIENTATION_COEFFICIENT .* orientationMap);
        sMap = sMap + (COLOR_COEFFICIENT .* colorDifferenceMap);
        sMap = sMap + (MOTION_COEFFICIENT .* motionMap);
        sMap = sMap ./ (CONTRAST_COEFFICIENT + ORIENTATION_COEFFICIENT + COLOR_COEFFICIENT + MOTION_COEFFICIENT);
        
        % Apply the inhibition map to the saliency map!
        sMapNew = sMap .* inhibitionMap;

        % Find the most salient region (square)
        [ulX, ulY, width, height] = FindSalientRegion(sMapNew);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Recalucate the coefficients %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % each component gets a 1.0 weight, there is an extra 25% weight up
        % for grabs which gets distributed by % of the current region
        intensityTotal = sum(sum(intensityContrastMap(ulY:ulY+height,ulX:ulX+width)));
        orientationTotal = sum(sum(orientationMap(ulY:ulY+height,ulX:ulX+width)));
        colorTotal = sum(sum(colorDifferenceMap(ulY:ulY+height,ulX:ulX+width)));
        motionTotal = sum(sum(motionMap(ulY:ulY+height,ulX:ulX+width)));
        
        total = intensityTotal + orientationTotal + colorTotal + motionTotal;
        CONTRAST_COEFFICIENT = 1.0 + 0.25 * (intensityTotal / total);
        ORIENTATION_COEFFICIENT = 1.0 + 0.25 * (orientationTotal / total);
        COLOR_COEFFICIENT = 1.0 + 0.25 * (colorTotal / total);
        MOTION_COEFFICIENT = 3.0 + 0.25 * (motionTotal / total);

        % Update the inhibiton map
        %    - First update all the clusters
        %    - Then apply the clusters (i.e. build the inhibition map)
        clusters{size(clusters,2)+1} = {ulX,ulY,width,height,1,STARTING_CLUSTER_LIFE};
        inhibitionMap = ApplyClusters(clusters, inhibitionMap);

        inhibitionOutput = zeros(frameHeight,frameWidth,3);
        
        red = inhibitionMap(:,:);
        green = inhibitionMap(:,:);
        blue = inhibitionMap(:,:);
        red(find(red>1)) = red(find(red>1)) - 1.0; %1.2;
        red(find(red<=1)) = 0;
        green = inhibitionMap == 1;
        blue(find(blue<1)) = 1 - blue(find(blue<1));
        blue(find(blue>=1)) = 0;
        
        inhibitionOutput(:,:,1) = red;
        inhibitionOutput(:,:,3) = blue;
        inhibitionOutput(:,:,2) = 0;
        
        fprintf(1,'Complete! ');
    else
         fprintf(1,'Skipping!\n');
    end
    
    % if we are resampling our data, recalulate some values
    if(resampleData==1)
        ulX = floor(ulX * aspectRatio);
        ulY = floor(ulY * aspectRatio);
        width = floor(width * aspectRatio);
        height = floor(height * aspectRatio);
    
        % reset the frame to it's original size
        frameRGB = frameRGBOriginal;
    end
   
    width = floor(width/3.0);
    height = floor(height/3.0);
    ulX = ulX+width;
    ulY = ulY+height;
    
    image = BoundingBox(frameRGB, ulX, ulY, width, height);  
    
    % Extract the region inside the boudning box
    extractedRegion = frameRGB(ulY:ulY+height-1, ulX:ulX+width-1,:);
    
    
    % -- Display Intermediate Output For Testing Mode Only --
    if(testingOutput)
        figure, imshow(resizedFrame), title('Original Image');
        figure, imshow(intensityContrastMap), title('Intensity Contrast Map'), colormap('cool'), colorbar;
        figure, imshow(orientationMap), title('Orientation Map'), colormap('cool'), colorbar;
        figure, imshow(colorDifferenceMap), title('Color Difference Map'), colormap('cool'), colorbar;
        figure, imshow(motionMap),title('Motion Map'), colormap('cool'), colorbar;
        figure, imshow(sMap), title('sMap with motion and inhibition'), colormap('hot'), colorbar;
        figure, imshow(inhibitionMap), title('Inhibition Map'), colormap('hot'), colorbar;
        figure, imshow(sMapNew), title('sMap with inhibition map'), colormap('hot'), colorbar;
        figure, imshow(image), title('Boxed');
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                                                       %
    % Depending on the flags set at the top of the program, %
    % render different types of output into various files   %
    % and folders.                                          %
    %                                                       %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if(showSaliencyOutput == 1)
        filename = strcat('SaliencyOutput/','image_',num2str(currFrame),'.bmp');
        imwrite(sMapNew,filename);
    end
    
    if(showBoxedOutput == 1)
        filename = strcat('BoxedOutput/','image_',num2str(currFrame),'.bmp');
        imwrite(image,filename);
    end
    
    if(showExtractedOutput == 1)
        filename = strcat('ExtractedOutput/','extracted_',num2str(currFrame),'.bmp');
        imwrite(extractedRegion,filename);
    end
    
    if(showFrameOutput == 1)
        filename = strcat('FrameOutput/','frame_',num2str(currFrame),'.bmp');
        imwrite(frameRGB,filename);
    end

    if(showInhibitionOutput == 1)
        filename = strcat('InhibitionOutput/','image_',num2str(currFrame),'.bmp');
        imwrite(inhibitionOutput,filename);
    end
   
    if(showPositionOutput == 1)
        WriteBB2File(currFrame,ulX,ulY,width,height);
    end
end