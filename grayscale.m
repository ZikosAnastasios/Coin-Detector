function GRAY = grayscale(IMG)

% convert image to grayscale using custom code
GRAY = 0.25 * IMG(:,:,1) + 0.5 * IMG(:,:,2) + 0.25 * IMG(:,:,3);

end