function A = gaussian_filter(kernel_radius, sigma)

assert(kernel_radius > 0, 'Kernel size should greater than zero');

% if kernel_radius == 1 it creates a kernel of size 3x3 : (-1 0 1)
% kernel_radius == 2 it creas a kernel of size 5x5 : (-2 -1 0 1 2)
% ..

% precompute : 2 * s^2
two_sigma_squared = 2 * sigma * sigma;

A = ones(2 * kernel_radius + 1);
sum = 0.0;

for x = -kernel_radius:1:kernel_radius
    for y = -kernel_radius:1:kernel_radius
        % gaussian function
        weight = exp( -(x*x + y*y) / two_sigma_squared) / (two_sigma_squared * pi);
        A(x + kernel_radius + 1, y + kernel_radius + 1) = weight;
        % sum the coefficient to do a normalization later
        sum = sum + weight;
    end
end

%normalize due to energy loss
A = A / sum;

end