function show_misregistration(filename)
%% show the cross-band misregistration of the original hyperspectral image

if strcmp(filename(end-3:end), '.mat')
    datacube=importdata(filename);
else
[datacube, bandname, description] = Load_Spec(filename);
end
addpath('E:\matlab\vlfeat-0.9.17\toolbox\sift');
dot = zeros(41,2);
%when the images become clear, let's have a try without no resize.
datacube = normalise(datacube,'percent', 0.999);
I = squeeze(datacube(:,:,25));
h = figure,
imshow(I);
rect = getrect(h);
hold all,
rectangle('Position',rect,'EdgeColor','r', 'LineWidth',2);
%rect = int16([rect(2) rect(1) rect(4) rect(3)]);
rect = int16(rect);
j = 1;
for i = 21: 55 
    slice = squeeze(datacube(:,:,i));
    corners = detectHarrisFeatures(slice, 'ROI', rect, 'FilterSize', 5, 'MinQuality', 0.01);
   % imshow(I); hold on;
    c = corners.selectStrongest(1);
    plot(c);
    dot(j, :) = c.Location;
   % hold off;
    j = j + 1;
end







