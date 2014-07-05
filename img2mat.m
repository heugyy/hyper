function mat = img2mat(varargin)
%% mat = img2mat(folder, subffix, bandRange, saveName, filter)
folder = varargin{1};
if 2 == length(varargin)
    subffix = varargin{2};
elseif 3 == length(varargin)
    subffix = varargin{2};
    band = varargin{3};
elseif 4 == length(varargin)
    subffix = varargin{2};
    band = varargin{3};
    matname = varargin{4};
elseif 5 == length(varargin)
    subffix = varargin{2};
    band = varargin{3};
    matname = varargin{4};
    filter = 'gaussian';
end

cd(folder);
list = dir(fullfile(folder,subffix));
b = length(list);
filename = list(1).name;
slice = imread(filename);
[m, n] = size(slice);
mat = zeros([m, n, b], 'uint8');
    
for i = 1:b
    filename = ['P0W', num2str(band(i)),subffix(2:end)];
    slice = imread(filename);
    if exist('filter', 'var')
        gaussianFilter = fspecial('gaussian', 3, 0.8);
        slice = imfilter(slice, gaussianFilter);
    end
    mat(:,:,i) = slice;
    imshow(slice);
    disp(i);
end

cd ..;
if isempty(matname)
    matname = 'hyperface.mat';
end

save(matname, 'mat');
