%%segment plant out of scene
function spec_segment(filename)
if strcmp(filename(end-3:end), '.mat')
    mat=importdata(filename);
else
    datacube = Load_Spec(filename);
    mat = normalise(datacube);
end
[m, n, b] = size(mat);
X = reshape(mat, [m*n,b]);
sample = importdata('sample.mat');
IDX = kmeans(X, 2, 'Distance', 'cosine',  'Start', sample);
%classes = reshape(IDX, [m, n]);

% crop = classes( 1:800, 200:1200);
% figure,
% imagesc(crop);

slice = squeeze(mat(1:800, 200:1200, 26));
figure,
imshow(slice);
imgname = regexprep(filename,'.mat','.jpg', 'ignorecase');
imwrite(slice,['.\', 'slicefull', '\', imgname]);  

% X(IDX == 1, :) = 0;
% plant = reshape(X, [m, n, b]);
% sliceplant = squeeze(plant(1:800, 200:1200, 26));
% figure, imshow(sliceplant);
% % matname = regexprep(filename,'.mat','_c.mat', 'ignorecase');
% % save(matname,'plant');
% imgname = regexprep(filename,'.mat','.jpg', 'ignorecase');
% imwrite(sliceplant,['.\', 'slice', '\', imgname]);  