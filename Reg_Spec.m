function Reg_Spec(filename)
%%register the datacube from 600:1000 and 500:600 separately.

%potential problems, the anchor could lie out of band 580-640, then these
%bands all need to be registered.

%read datacube
[d, bandname, ~] = Load_Spec(filename);
odatacube = normalise(d,'percent', 0.999);
clear d;
datacube = odatacube(:,:,end-50:end);
bandname = bandname(end-50 : end);
[~, ~, b] = size(datacube);  
endl = 7; % the end of low channel
starth = 16; % the beginning of high channel
c = zeros(b,1); %choose the anchor by measuring the contrast

%initial registration parameters
for i=1:b
    slice = datacube(:,:,i);
    c(i,1) = fmeasure(slice, 'GDER',[]);   
end
[~,index] = max(c);
anchor = datacube(:,:,index);
anchor = imadjust(anchor);

 % the number of images which don't need to register
scale = ones(b,1);
theta = zeros(b,1);
tx = zeros(b,1);
ty = zeros(b,1);
band = zeros(b,1);

for i = 1:1:b % from middle to high wavelength 
    if i<starth && i>endl
        continue;
    end
    target = datacube(:,:,i);  
    target = imadjust(target);
    tform = imregtform2(target, anchor);
    T = tform.T;
    ss = T(2,1);
    sc = T(1,1);
    scale(i,1) = sqrt(ss*ss + sc*sc);
    theta(i,1) = atan2(ss,sc)*180/pi;
    tx(i,1) = T(3,1);
    ty(i,1) = T(3,2);
    band(i,1) = bandname(i);
    disp(i);
end

%fit transform parameters scale, tx, ty
Trl = makeTransform(band(1:endl),scale(1:endl),theta(1:endl),tx(1:endl),ty(1:endl), bandname(1:endl)); %low channeal
Trh = makeTransform(band(starth:end),scale(starth:end),theta(starth:end),tx(starth:end),ty(starth:end), bandname(starth:end)); %high channeal
tempmat = repmat(eye(3), 8, 1);
Trm = mat2cell(tempmat, [3 3 3 3 3 3 3 3], [3]); %those bands do not need to be registered
Tr = [Trl; Trm; Trh];
matname = regexprep(filename,'.dat','_T.mat', 'ignorecase');
save(matname, 'bandname', 'scale', 'tx', 'ty');


%tranform every slice
for i = 1: b % from middle to left 
    target = datacube(:,:,i);  
    tform = affine2d(Tr{i});
    register = imwarp(target, tform, 'OutputView', imref2d(size(target)));
    datacube(:,:,i) = register;
end
% if the anchor is out of the 600 - 650 nm, these bands also need to be
% registered
%if index > 5

odatacube(:,:,11:61) = datacube;    
%save the registered data
output = im2uint16(odatacube);
dataname = regexprep(filename,'.dat','_r.mat', 'ignorecase');
save(dataname, 'output');



function Tr = makeTransform(band,scale,theta,tx,ty, varargin)
if isempty(varargin)
    bandname = [400:10:1000]';
else bandname = varargin{1};
end
l = length(bandname);
theta = theta*pi/180;
f2 = fit(band,scale,'poly2');
scalefit = feval(f2,bandname);
%figure, 
plot(band,scale,'r*',bandname,scalefit,'g');
title('scale');
xlabel('wavelength (nm)');
ylabel('scale');
thetafit = zeros(l,1);
%figure,
%plot(band,theta,'r',bandname,thetafit,'g');
%title('theta');
%xlabel('wavelength (nm)');
%ylabel('rotation (degree)');

f2 = fit(band,tx,'poly2');
txfit = feval(f2,bandname);

%figure, 
plot(band,tx,'r*',bandname,txfit,'g');
title('tx');
xlabel('wavelength (nm)');
ylabel('shift (pixel)');


f2 = fit(band,ty,'poly2');
tyfit = feval(f2,bandname);
%figure, 
plot(band,ty,'r*',bandname,tyfit,'g');
title('ty');
xlabel('wavelength (nm)');
ylabel('shift (pixel)');

T = cell(l,1);
for i=1:l
     T{i} = [scalefit(i)*cos(thetafit(i)) -scalefit(i)*sin(thetafit(i)) 0;...
             scalefit(i)*sin(thetafit(i)) scalefit(i)*cos(thetafit(i)) 0;...
             txfit(i)                     tyfit(i)                  1];
end
Tr = T;