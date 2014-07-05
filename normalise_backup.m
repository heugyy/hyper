function n = normalise(datacube)
%if ~isa(datacube,'double')
%    datacube = double(datacube); 
%end
datacube = im2double(datacube);
minnum = min(datacube(:));
maxnum = max(datacube(:));
n = (datacube - minnum) / (maxnum-minnum);