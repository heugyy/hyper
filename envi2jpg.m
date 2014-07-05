function envi2jpg(filename)
datacube = Load_Spec(filename);
mat = normalise(datacube);

img600 = mat(:,:,21);
img700 = mat(:,:,31);
img800 = mat(:,:,41);
img900 = mat(:,:,51);

imgname600 = regexprep(filename,'.dat','_600.jpg', 'ignorecase');
imgname700 = regexprep(filename,'.dat','_700.jpg', 'ignorecase');
imgname800 = regexprep(filename,'.dat','_800.jpg', 'ignorecase');
imgname900 = regexprep(filename,'.dat','_900.jpg', 'ignorecase');

imwrite(img600, imgname600, 'jpg');
imwrite(img700, imgname700, 'jpg');
imwrite(img800, imgname800, 'jpg');
imwrite(img900, imgname900, 'jpg');
