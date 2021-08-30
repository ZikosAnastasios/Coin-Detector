clear;
clf;

% ZIKOS ANASTASIOS - 3160037
% DIMITRIOS LIAROPOULOS - 3160262

% - Thresh: (Threshold) is the minimal ratio of the number of detected edge
%          pixels to 0.9 'times' the calculated circle perimeter
%          (0<thresh<=1, default: 0.33).
% - Delta: is the maximal difference between two circles for them to
%          be considered as the same one (Delta=39 in order to achieve our result).
% - minR:  minimal radius in pixels
% - maxR:  maximal radius in pixels
Thresh = 0.33;
Delta = 38;
minR = 37;
maxR = 53;


% We ask the user what image he wants to use
prompt = 'What Image would you like to use?';
x = input(prompt);

% We load the Image
Image = imread(x);
figure(1);
displayImage(Image);
title('Original Image');


% We convert the image of uint8 (0-255) to single (0.0-1.0)
Image = single(Image) / 255;


% We get the width and height of the image
[height, width, channels] = size(Image);


% We compute a gaussian filter of kernel size 5x5 and sigma 20
%myfilter = fspecial('gaussian',[5 5], 20);
myfilter = gaussian_filter(2, 20);


% We convert the A image to a grayscale image
Gray = grayscale(Image);
Original = Gray;


% We convolve the grayscale image with the gaussian filter
Gaussian = convn(Gray, myfilter, 'same');


% We create a 3D Hough array with the first two dimensions specifying the
% coordinates of the circle centers, and the third specifying the radii.
% To accomodate the circles whose centers are out of the image, the first
% two dimensions are extended by 2*maxR.
maxR2 = 2*maxR;
Hough = zeros(size(Gray,1)+maxR2, size(Gray,2)+maxR2, maxR-minR+1);


% For an edge pixel (ex ey), the locations of its corresponding, possible
% circle centers are within the region [ex-maxR:ex+maxR, ey-maxR:ey+maxR].
% That's why the grid [0:maxR2, 0:maxR2] is first created, and then the distances
% between the center and all the grid points are computed to form a radius
% map (RadiusMap), followed by clearing out-of-range radii.
[X, Y] = meshgrid(0:maxR2, 0:maxR2);
RadiusMap = round(sqrt((X-maxR).^2 + (Y-maxR).^2));
RadiusMap(RadiusMap<minR | RadiusMap>maxR) = 0;


% We detect edge pixels using Sobel filter. We apply the Gaussian filter
% on the Sobel filtered image in order to reduce more noise.
% For each edge pixel, we increment the corresponding elements in the Hough
% array (vote method). (Ex Ey) are the coordinates of edge pixels and (Cy Cx R)
% are the centers and radii of the corresponding circles.    
MySobel = sobel(Gaussian);
EdgeImage = convn(MySobel, myfilter, 'same');
for y = 1:height
    for x = 1:width
        % count only the pixels with value greater than 0.51
        % and less than 0.80
        if(EdgeImage(y,x) > 0.51 && EdgeImage(y,x) < 0.80)
            EdgeImage(y,x) = 1;
        else
            EdgeImage(y,x) = 0;
        end
    end
end       
[Ey, Ex] = find(EdgeImage);
[Cy, Cx, R] = find(RadiusMap);
for i = 1:length(Ex)
  Index = sub2ind(size(Hough), Cy+Ey(i)-1, Cx+Ex(i)-1, R-minR+1);
  Hough(Index) = Hough(Index)+1;
end


% We collect candidate circles.
% Due to digitization, the number of detectable edge pixels are about 90%
% of the calculated perimeter. That's the reason we multiply 2*pi by 0.9.
twoPi = 0.9*2*pi;
Circles = zeros(0,4);    % Format: (x y r t)
for radius = minR:maxR   % Loop from minimal to maximal radius
  Slice = Hough(:,:,radius-minR+1);  % Offset by minR
  twoPiR = twoPi*radius;
  Slice(Slice<twoPiR*Thresh) = 0;  % Clear pixel count < 0.9*2*pi*R*Thresh
  [y, x, count] = find(Slice);
  Circles = [Circles; [x-maxR, y-maxR, radius*ones(length(x),1), count/twoPiR]];
end


% We delete similar circles
Circles = sortrows(Circles,-4);  % Descending sort according to ratio
i = 1;
while i<size(Circles,1)
  j = i+1;
  while j<=size(Circles,1)
    if sum(abs(Circles(i,1:3)-Circles(j,1:3))) <= Delta
      Circles(j,:) = [];
    else
      j = j+1;
    end
  end
  i = i+1;
end


% Coin Counters
TenCounter = 0;
FiftCounter = 0;
OneCounter = 0;
TwoCounter = 0;


% We draw circles and we count each coin type
figure(2);
displayImage(Original);
title('Final Image');
for i = 1:size(Circles,1)
  x = Circles(i,1)-Circles(i,3);
  y = Circles(i,2)-Circles(i,3);
  w = 2*Circles(i,3);  
  
  % 2-euro coin counter
  if(Circles(i,3)>48.0000)
     rectangle('Position', [x y w w], 'EdgeColor', 'red', 'Curvature', [1 1], 'LineWidth', 2);
     TwoCounter = TwoCounter + 1;
  end
  
  % 50-cent coin counter
  if(Circles(i,3)>46.0000 && Circles(i,3)<=48.0000)
      rectangle('Position', [x y w w], 'EdgeColor', 'green', 'Curvature', [1 1], 'LineWidth', 2);
      FiftCounter = FiftCounter + 1;
  end
  
  % 1-euro coin counter
  if(Circles(i,3)>42.0000 && Circles(i,3)<=46.0000)
      rectangle('Position', [x y w w], 'EdgeColor', 'blue', 'Curvature', [1 1], 'LineWidth', 2);
      OneCounter = OneCounter + 1;  
  end
  
  % 10-cent coin counter, we exclude circles that might
  if(Circles(i,3)>=37.000 && Circles(i,3)<=42.000)
      rectangle('Position', [x y w w], 'EdgeColor', 'magenta', 'Curvature', [1 1], 'LineWidth', 2);
      TenCounter = TenCounter + 1;
  end
end


% We display the results in the command window.
TWO = ['There are ', num2str(TwoCounter),' 2-Euro coins in the image'];
FIF = ['There are ', num2str(FiftCounter),' 50-cent coins in the image'];
ONE = ['There are ', num2str(OneCounter),' 1-Euro coins in the image'];
TEN = ['There are ', num2str(TenCounter),' 10-cent coins in the image'];
disp(TWO);
disp(FIF);
disp(ONE);
disp(TEN);