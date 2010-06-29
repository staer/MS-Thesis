function filter = CreateGDFilter(filterSize, n, p, x0, y0, t0, theta, phi, sx, sy, st, k)
% CREATEGDFILTER creates a Gaussian Derivative filter based on the paper
% written by R.A. Young - "The Gaussian Derivative model for
% spatial-temporal vision: I. Cortical model"
%
% Paramters:
%   n: space time number specifying shape and number of lobes
%   p: space time number specifying shape and number of lobes
%   x0: x offset
%   y0: y offset
%   t0: t offset
%   theta: spatial orientation
%   phi: space-time orientation   
%   sx: x-scale
%   sy: y-scale
%   st: t-scale
%   k: amplitude paramter
%
% Returns:
%   A (size by size by size) Gaussian Derivative filter.
%
% Note: Based on Dr. Roger Gaborski's code, modified by Daniel Harris

% Calculate Sigma^2 values for the Gaussian functions
sx2 = sx * sx; 
sy2 = sy * sy;
st2 = st * st;

% Standard definitions                  --> Equation C2
%   x1 = (x-x0)
%   y1 = (y-y0)
%   t1 = (t-t0)

% Definitions for theta and phi rotation angles:
% Theta:                                --> Equation C3
%   x2 = cos(theta)*x1 + sin(theta)*y1
%   y2 = -sin(theta)*x1 + cos(theta)y1
%   t2 = t1
%
% Phi:                                  --> Equation C4
%   x' = cos(phi)*x2 - sin(phi)*t2
%   y' = y2;
%   t' = sin(phi)*x2 - sin(phi)*t2


% Vector of length 41
% NOTE: This could/should change based on a paramter? 
% Will stay at 41x41x41 for now...
%index = [-2:.1:2];
%filter = zeros(41,41,41);

%index = [-2:.2:2];
%filter = zeros(21,21,21);

%index = [-2:.4:2];
index = linspace(-2,2,filterSize);
filter = zeros(filterSize,filterSize,filterSize);

for x = 1:length(index)
    for y = 1:length(index)
        for t = 1:length(index)
            
            % Calculate x1,y1,t1
            x1 = x - x0;
            y1 = y - y0;
            t1 = t - t0;
            
            % Calculate x2,y2,t2 (theta rotation)
            x2 = cosd(theta)*index(x1) + sind(theta)*index(y1);
            y2 = -1*sind(theta)*index(x1) + cosd(theta)*index(y1);
            t2=index(t1);
            
            % Calculate x3,y3,t3 (phi rotation)
            x3 = cosd(phi)*x2 - sind(phi)*t2;
            y3 = y2;
            t3 = sind(phi) * x2 + cosd(phi)*t2;
            
            % Calculate the 3 components based on parameters
            % The Gaussian Derivative Function:
            %
            % G0(x) = K*e^(-x^2/2*sigma(x)^2)       --> Equation C1
            % G1(x) = -x*G0(x)                      --> Equation B3
            % G2(x) = (x^2-1)G0(x)                  --> Equation B4
            % G3(x) = -(x^3-3x)G0(x)                --> Equation B5
            % G4(x) = (x^4-6x^2+3)G0(x)             --> Equation B6
            
            Gx = k* exp(( -1*x3*x3)/(2*sx2));   % G0
            Gy = k* exp(( -1*y3*y3)/(2*sy2));   % Y0
            Gt = k* exp(( -1*t3*t3)/(2*st2));   % T0
            
            % Calculate Gx
            if(n==1)
                Gx = -1*(x3/sx2)* Gx;
            end
            if(n==2)
                Gx = (1/sx2) * ( ((x3 * x3)/ sx2)-1)*Gx;
            end

            % Calculate Gt 
            if(p==1)
                Gt = -1*(x3/st2)* Gt;
            end
            
            % The Gaussian Derivative Spatio-Temporal Model as Described by Young:
            % Gn,o,p(x',y',t') = Gn(x')go(y')gp(t') for n,o,p = 0,1,2,....
            % where Gn,Go,Gp are the Gaussian derivatives along the x',y',t' axis
            filter(x,y,t) = Gx * Gy * Gt;
        end
    end
end

% Normalize the filter so the range is -1 to +1
filterMax = max(max(max(filter)));
filter = filter ./ filterMax;



