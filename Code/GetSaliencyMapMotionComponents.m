function [motionMap, motionBuffer] = GetSaliencyMapMotionComponents(inputFile, frameNum, blinkFilter, dFilters, resampleData, buffer)
% Get the motion feature map (and buffer) for a input file and current
% frame number

maxBlinkResponse = 0;
maxDirectionResponse = 0;

for r=1:size(blinkFilter,3)
    b = blinkFilter(:,:,r);
    maxBlinkResponse = maxBlinkResponse + sum(b(find(b>0)));
end

for r=1:size(dFilters{1},3)
    b = dFilters{1}(:,:,r);
    maxDirectionResponse = maxDirectionResponse + sum(b(find(b>0)));
end

fileinfo = aviinfo(inputFile);
% Calculate X frames of data using the blink filter to just pull out motion
width = fileinfo.Width;
height = fileinfo.Height;
if(resampleData==1)
    aspectRatio = fileinfo.Width / 320.0;
    width = 320;
    height = floor(fileinfo.Height / aspectRatio);
end
motionBuffer = zeros(height,width,size(dFilters{1},3));
currFrame = frameNum;
colorFrame = 0;
for m=1:size(dFilters{1},3)
    if(size(buffer,1)==1 || m==size(dFilters{1},3))
        blinkBuffer = zeros(height,width,size(blinkFilter,3));

        for i=1:size(blinkFilter,3)
            mov = aviread(inputFile,currFrame-floor(size(dFilters{1},3)/2)+i-1); 
            colorFrame = im2double(mov(1,1).cdata);
            frame = mat2gray(rgb2gray(im2double(mov(1,1).cdata)));

            if(resampleData==1)
                frame = imresize(frame, [height width]);
            end

            blinkBuffer(:,:,i) = frame;

        end

        % Convolve the blink filter with the blinkBuffer and store in
        % motionBuffer
        mb = abs(Convolve3D(blinkBuffer,blinkFilter));
        mb = mb ./ maxBlinkResponse;
        motionBuffer(:,:,m) = mb;
        currFrame = currFrame+1;
    else
        motionBuffer(:,:,m) = buffer(:,:,m+1);
    end
end

% Calculate 4 motion maps in each of the 4 directions (0, 45, 90, 135
% degrees)
motion0 = Convolve3D(motionBuffer,dFilters{1});
motion45 = Convolve3D(motionBuffer,dFilters{2});
motion90 = Convolve3D(motionBuffer,dFilters{3});
motion135 = Convolve3D(motionBuffer,dFilters{4});
motion0 = abs(motion0);
motion45 = abs(motion45);
motion90 = abs(motion90);
motion135 = abs(motion135);

motion0 = motion0 ./ maxDirectionResponse;
motion45 = motion45 ./ maxDirectionResponse;
motion90 = motion90 ./ maxDirectionResponse;
motion135 = motion135 ./ maxDirectionResponse;

% Combine the 4 intermediate motion maps into one master motion map
motionMap = motion0 + motion45 + motion90 + motion135;
motionMap = motionMap ./ max(motionMap(:));
motionMap(find(motionMap>1)) = 1;
s