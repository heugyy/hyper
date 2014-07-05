function envi2mat(filename)
datacube = Load_Spec(filename);
mat = normalise(datacube, 'percent', 0.999);
matname = regexprep(filename,'.dat','.mat', 'ignorecase');
save(matname, 'mat');