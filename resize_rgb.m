function area = resize_rgb(filename,varargin)
% resize datacube
img=imread(filename);
%[~, ~]=size(img);
figure
imshow(img);
if isempty(varargin) 
    position = importdata('position.mat');
else position = varargin{1};
end

h = imrect(gca, position);
rect = wait(h);
close gcf;
area=img(round(rect(2)):round(rect(2)+rect(4)-1),round(rect(1)):round(rect(1)+rect(3)-1),:);
imgname = regexprep(filename,'.jpg','_c.jpg', 'ignorecase');
imwrite(area, imgname);
