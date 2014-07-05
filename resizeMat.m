function resizeMat(filename)

data = importdata(filename);
if 	ndims(data) == 3
    datacube = im2uint8(data);
    dataname = regexprep(filename,'_r.mat','.mat', 'ignorecase');
    save(dataname, 'datacube'); 
    disp(filename);
end
    