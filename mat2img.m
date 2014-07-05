function mat2img(varargin)
% transfer mat into folder with slices
% input: mat, band, folderName
mat = varargin{1};
if max(mat(:))>1
   intMat = uint8(mat);
else
   intMat = uint8(mat*255); 
end
[m, n, b]=size(intMat);
band = 1:b;
folderName = 'bands';
if 2 == length(varargin)
    band = varargin{2};
elseif 3 == length(varargin)
    band = varargin{2};
    folderName = varargin{3};
end
mkdir(folderName);
for i=1:b
        slice = squeeze(intMat(:,:,i));
        fileName = fullfile(folderName, [int2str(band(i)),'.bmp']);
        imwrite(slice,fileName);  
end