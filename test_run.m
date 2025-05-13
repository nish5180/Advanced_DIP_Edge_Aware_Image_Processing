img = imread('peppers.png');     % Load a color image
gray_img = rgb2gray(img);  
lvl=5;
pyr = create_gaussian_pyramid(gray_img, lvl);

figure;
for i = 1:lvl
    subplot(1, lvl, i);
    imshow(pyr{i});
    title(sprintf('Level %d', i));
end


function g = get_guide_value(pyr, l, x, y)
% pyr: Gaussian pyramid 
% l: level index
% x, y: pixel location at that level
% g: scalar guide value at (x, y) in level l

    g = pyr{l}(y, x);  
end

