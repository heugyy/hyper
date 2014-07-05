function datacube = readCMUHyperData(filename, varargin)
data = importdata(filename,'basic');
basis = data.basis;
illuminant = data.illuminant;
mcCOEF = data.mcCOEF;
if ~isempty(basis) && ~isempty(varargin)
    oldWave    = basis.wave;
    newWave    = varargin{1};
    nBases     = size(basis.basis,2);
    extrapVal  = 0;
    newBases   = zeros(length(newWave),nBases);
    for ii=1:nBases
        newBases(:,ii) = interp1(oldWave(:), basis.basis(:,ii), newWave(:),'linear',extrapVal);
    end
    basis.basis = newBases;
    basis.wave = newWave;
end

[height, width, band] = size(mcCOEF);
XWdata = reshape(mcCOEF, height*width, band);
newband = size(basis.basis,1);
XWDecompress = XWdata*(basis.basis)';
Decompress = reshape(XWDecompress,height, width, newband);
slice = squeeze(Decompress(:,:, 60));
imagesc(slice);

