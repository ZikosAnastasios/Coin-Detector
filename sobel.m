function A = sobel(IMG)

% get the number of channels of the Image
[~, ~, channels] = size(IMG);

% if the image is not grayscale, complain
assert(channels == 1, 'A grayscale image should be provided');

%Sobel filter kernel
Gx = [-1 0 1; -2 0 2; -1 0 1];
Gy = [-1 -2 -1; 0 0 0; 1 2 1];

GRADIENT_X = conv2(IMG, Gx,'same');
GRADIENT_Y = conv2(IMG, Gy,'same');

A = abs(GRADIENT_X) + abs(GRADIENT_Y);

end