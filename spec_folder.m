function spec_folder(filename)
%%abstract slice from datacube and put them into same folders
if strcmp(filename(end-3:end), '.mat')
    mat=importdata(filename);
else
    datacube = Load_Spec(filename);
    mat = normalise(datacube);
end
%folder = regexprep(filename,'_rc.mat','', 'ignorecase');
folder = regexprep(filename,'.mat','', 'ignorecase');
mkdir(folder);
for j = 1:1:41
    slice = mat(:,:,j);
    slice = imadjust(slice);   
    wl = 600 + 10*(j-1);
    imgname = regexprep(filename,'_rc.mat',['_', num2str(wl), '.jpg'], 'ignorecase');
    imwrite(slice,['.\', folder, '\', imgname]);    
end
    