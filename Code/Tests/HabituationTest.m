
taum = 10; % 50 or 10
tsyn = 4; % 2,8
x = [1:90];
y = (exp(-1*x/taum))-(exp(-1*x/tsyn)); 
% Above: 2 component exponential function for modeling firing rate of neurons

figure, plot(x,y), title('Scaling function');



ulY = 50;
ulX = 50;
width = 100;
height = 100;
for f=0:1:20%0
    inhibitionMap = ones(240,320);
    sigmaEx = .416666*width;
    sigmaInh = .125*width;
    cEx = .1458*width;
    xInh = 0625*width;
    
    % Create the difference of gaussian filter
    region = DoGFilter2(width,sigmaEx,sigmaInh,3.5,1.5); 
    % Shift it based on the corner? (make sure the corner is at y=0)
    region = region - region(1,1);%ceil(width/2));
    
    % Scale from -1 to 1
    region = region ./ max(abs(region(:)));
    %figure,plot(1:width, region(floor(width/2),:)),grid
    
    % Scaling function (defined above)
    out = (exp(-1*f/taum))-(exp(-1*f/tsyn));
    %out = out * 2;
    
    %if f<50
        region = region * out;%;%(f*.01);
        %region = region ;
    %else
    %    region = region * (.5 - ((f-50)*.01));
    %end
    
    inhibitionMap(ulY:ulY+height-1, ulX:ulX+width-1) = inhibitionMap(ulY:ulY+height-1, ulX:ulX+width-1) + (region);
    [x y] = meshgrid(1:320, 1:240);
    figure, mesh(x,y,inhibitionMap), zlim([0.25 1.25]);
    
end
