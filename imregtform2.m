
function tform = imregtform2(varargin)

moving = double(varargin{1});
fixed = double(varargin{2});
initialT = [1 0 0 0];
mfirst= [1 1];
mspacing = [1 1];
ffirst = [1 1];
fspacing = [1 1];
dispOptim = false;
transformType = 'similarity'; 
transformParams = initialT;
optimObj = registration.optimizer.OnePlusOneEvolutionary;
optimObj.GrowthFactor = 1.2;
optimObj.Epsilon = 3.0e-3;
optimObj.InitialRadius = 6.25e-3;
optimObj.MaximumIterations = 300;
metricConfig = registration.metric.MattesMutualInformation;
metricConfig.NumberOfSpatialSamples = 500;
metricConfig.NumberOfHistogramBins = 50;
metricConfig.UseAllPixels = 1;
pyramidLevels = 2;

%mref = imref2d(size(moving));
fref  = imref2d(size(fixed));
optimObj.Scales = [1 1e6 1 1];
[rotationMatrix, translationVector] = ...
    regmex(...
    moving, ...
    mfirst,...
    mspacing,...
    fixed,...
    ffirst,...
    fspacing,...
    dispOptim,...
    transformType, ...
    transformParams, ...
    optimObj, ...
    metricConfig,...
    pyramidLevels);

tform = getGeometricTransform(fref,rotationMatrix, translationVector);
end

function tform = getGeometricTransform(fref,rotationMatrix, translationVector)
% Convert the regmex registration parameters to a tform struct

% The incoming rotation and translation information aligns the *fixed* to
% the *moving*.

if(isa(fref,'imref3d'))
    % 3D
    nDims = 3;
    rotCentOffset = [mean(fref.YWorldLimits) mean(fref.XWorldLimits) mean(fref.ZWorldLimits)];
else
    % 2D
    nDims = 2;
    rotCentOffset = [mean(fref.YWorldLimits) mean(fref.XWorldLimits)];
end

% Use a composite affine transform matrix to perform the conversion.
A1 = eye(nDims+1);
A2 = eye(nDims+1);
A3 = eye(nDims+1);
A4 = eye(nDims+1);

% Affine transform to move origin to center of fixed image.
A1(end,1:nDims)     = -rotCentOffset;
% Rotation about the center of the *fixed* image to register it to the *moving*.
A2(1:nDims,1:nDims) = rotationMatrix;
% Move origin back
A3(end,1:nDims)     = rotCentOffset;

% Compute the final rotation about the first pixel of the fixed image
finalTransform = A1*A2*A3;

% Include the computed registration translation. This moves the *fixed* to
% the *moving*.
A4(end, 1:nDims) = translationVector;
finalTransform   = finalTransform*A4;

% While optimizing, regmex works with a transform which moves the fixed image
% to the moving image space. Invert the transform to obtain coefficients to
% register the moving to the fixed.
tWorld= eye(nDims+1,nDims+1)/finalTransform;

% Estimate of regmex is in terms of [r c 1] point specifications, not [x y 1] used by
% imwarp. We need to manipulate the form of the transformation matrix to
% move to account for this. A full derivation of this appears in the
% technical reference. We need to swap the X and Y components of
% translation and rotate the rotation matrix 180 degrees.
tWorld(1:2,1:2) = rot90(tWorld(1:2,1:2),2);
tWorld(end,1:2) = fliplr(tWorld(end,1:2));

% Clean up final column of tWorld to account for any numeric error
% introduced when inverting transformation.
tWorld(1:(end-1),end) = zeros(nDims,1);
tWorld(end,end) = 1;

if nDims == 2
    tform = affine2d(tWorld);
else
    % This is necessary for the 3-D case for account for [r c p 1] vs. [x y z 1] 
    % convention returned by regmex. See technical reference for derivation.
    tWorld(3,1:2) = fliplr(tWorld(3,1:2));
    tWorld(1:2,3) = flipud(tWorld(1:2,3));
    tform = affine3d(tWorld);
end

end