function area = resize_hyper(filename,varargin)
% resize datacube
S=importdata(filename);
[~, ~, b]=size(S);
slice = squeeze(S(:,:,floor(b/2)));
imshow(slice);
if isempty(varargin) 
    position = importdata('position.mat');
else position = varargin{1};
end

h = imrect(gca, position);
rect = wait(h);
close gcf;
area=S(round(rect(2)):round(rect(2)+rect(4)-1),round(rect(1)):round(rect(1)+rect(3)-1),:);
dataname = regexprep(filename,'_r.mat','_rc.mat', 'ignorecase');
save(dataname,'area');
