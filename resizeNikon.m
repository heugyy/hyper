function resizeNikon(filename)
% resize the Nikon original images whose data is very big
im = imread(filename);
[~, n, ~] = size(im);
if (n > 3000)
    img = imresize(im, 0.23); %1392/6016 = 0.2314
    imwrite(img, filename, 'jpg');
end