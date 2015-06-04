function varargout = View_Spec(varargin)
% Authors: Jie Liang, jie.liang@anu.edu.au
% Copyright  Computer Vision & Image Processing Lab @ Griffith Univeristy.
% Do not distribute.
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @View_Spec_OpeningFcn, ...
                   'gui_OutputFcn',  @View_Spec_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before View_Spec is made visible.
function View_Spec_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to View_Spec (see VARARGIN)

%addpath(genpath('C:\Users\s2882161\Documents\MATLAB\MatlabFns'));
addpath(genpath('E:\Matlab\tools\MTSNMF_denoising')); % add path of denoise function
set(handles.RadioGray,'value',1);
set(handles.RadioColor,'value',0);
set(handles.RadioOverlaid,'value',0);
set(handles.axes_spec, 'Visible', 'off');
axes(handles.axes_spec); cla;
axes(handles.axes1); cla; imshow('VA210.jpg');

% Choose default command line output for View_Spec
handles.output = hObject;
% Update handles structure
%h = warndlg('this vision is revised to read the second channel of hyperspectral images rather than the whole one!');
handles.version = 1;
guidata(hObject, handles);


% UIWAIT makes View_Spec wait for user response (see UIRESUME)
% uiwait(handles.MainFigure);

% --- Outputs from this function are returned to the command line.
function varargout = View_Spec_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in RadioColor.
function RadioColor_Callback(hObject, eventdata, handles)
% hObject    handle to RadioColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RadioColor
set(handles.RadioGray,'value',0);
set(handles.RadioOverlaid,'value',0);
RGB = handles.RGB;
axes(handles.axes1); cla; imshow(RGB,[]);
guidata(hObject, handles);

% --- Executes on button press in RadioGray.
function RadioGray_Callback(hObject, eventdata, handles)
% hObject    handle to RadioGray (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RadioGray
set(handles.RadioColor,'value',0);
set(handles.RadioOverlaid,'value',0);
bandname = handles.bandname;
band = get(handles.SliderWavelength, 'Value');
index = knnsearch(bandname,band);
set(handles.EditWavelength, 'String', num2str(bandname(index)));
slice = squeeze(handles.datacube(:,:,index));
imshow(slice, []);

% --- Executes on slider movement.
function SliderWavelength_Callback(hObject, eventdata, handles)
% hObject    handle to SliderWavelength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

band = get(handles.SliderWavelength, 'Value');
bandname = handles.bandname;
index = knnsearch(bandname,band);
set(handles.EditWavelength, 'String', num2str(bandname(index)));
slice = squeeze(handles.datacube(:,:,index));
axes(handles.axes1); cla; imshow(slice, [ ]);



% --- Executes on button press in ButtonAutoPlay.
function ButtonAutoPlay_Callback(hObject, eventdata, handles)
% hObject    handle to ButtonAutoPlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%datacube
bandname = handles.bandname;
for i=1:length(bandname)
    slice = squeeze(handles.datacube(:,:,i));
    axes(handles.axes1); cla;
    imshow(slice, []);
    set (handles.SliderWavelength,'Value',bandname(i));
    set (handles.EditWavelength, 'String', bandname(i));
    pause(0.3);
end


% --------------------------------------------------------------------
function Register_Callback(hObject, eventdata, handles)
% hObject    handle to Register (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
output = View_Spec_Register('View_Spec',handles.MainFigure);
if (~isempty(output)) && ndims(output) == 3
    handles.datacube = output;
end
guidata(hObject, handles); 
%test

% --------------------------------------------------------------------
function Analyse_Callback(hObject, eventdata, handles)
% hObject    handle to Analyse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
datacube = handles.datacube;
bandname = handles.bandname;
bandnum = length(bandname);
interval = bandname(2)-bandname(1);
sequence = zeros(bandnum, 4);% analyse results
sequence(:,1) = bandname; 
focus = zeros(bandnum,1);

for i=1:bandnum
    slice = squeeze(datacube(:,:,i));
    focus(i,1) = fmeasure(slice, 'GDER',[]);   
end
scrsz = get(0,'ScreenSize');
h = figure(1);
set(h,'Position',[1 scrsz(4)/4 scrsz(3)/3 scrsz(4)/3],'Name','Focus Level Estimation');
bar(sequence(:,1),focus,'Facecolor',[0,0,1],'LineWidth', 0.1); xlim([bandname(1)-interval,bandname(end)+interval]);title('focus level');
[c,index] = max(focus);
handles.reference = index; 
handles.focus = focus;
guidata(hObject, handles);    



% --- Executes on button press in ButtonChangeRGB.
function ButtonChangeRGB_Callback(hObject, eventdata, handles)
% hObject    handle to ButtonChangeRGB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prompt = {'Enter bandname for red channel(400-1000):','Enter bandname for green channel(400-1000):','Enter bandname for blue channel(400-1000):'};
dlg_title = 'RGB Channels:';
num_lines = 1;
def = {'650','550','500'};
answer = inputdlg(prompt,dlg_title,num_lines,def);
if (isempty(answer))
    return;
end
T1 = str2num(answer{1});
T2 = str2num(answer{2});
T3 = str2num(answer{3});
if (T1>1000) || (T1<400) || (T2>1000) || (T2<400) || (T3>=1000) || (T3<=400)
    return;
end
sliceR = squeeze(handles.datacube(:,:,floor((T1-handles.bandname(1))/10+1)));
%this is to show the error of registration error
% RGB(:,:,1) = imadjust(sliceR);
RGB(:,:,1) = sliceR;
sliceG = squeeze(handles.datacube(:,:,floor((T2-handles.bandname(1))/10+1)));
% RGB(:,:,2) = imadjust(sliceG);
RGB(:,:,2) = sliceG;
sliceB = squeeze(handles.datacube(:,:,floor((T3-handles.bandname(1))/10+1)));
% RGB(:,:,3) = imadjust(sliceB);
RGB(:,:,3) = sliceB;
handles.RGB = RGB;
axes(handles.axes1); cla; imshow(RGB,[]);
guidata(hObject, handles);    


% --------------------------------------------------------------------
function ToolSpectralProfile_OnCallback(hObject, eventdata, handles)
% hObject    handle to ToolSpectralProfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% set(handles.axes_spec,'Visible','On');
datacube = handles.datacube;
bandname = handles.bandname;
[~, ~, b] = size(datacube);
%axes(handles.axes1);
num = 6;
sample = zeros(num,b);
i = 1;
scrsz = get(0,'ScreenSize');
h = figure(100); hold all,
set(h,'Position',[10 scrsz(4)/4 scrsz(3)*0.3 scrsz(4)*0.4],'Name','Spectral Profile');
xlabel('Wavelength'); ylabel('Reflectance');

while strcmp(get(hObject,'State'),'on')
   %[x,y,but] = ginput(1);
   %rect = getrect(ax);
   rect = getrect(handles.axes1);
   roi = datacube(round(rect(2)):round(rect(2)+rect(4)),round(rect(1)):round(rect(1)+rect(3)),:);      
   spectral = squeeze(mean(mean(roi,1),2));
   sample(i,:) = spectral;
   assignin('base', 'temp', sample); 
   %imagehandle = plot(handles.axes_spec,bandname,spectral,'b');   
   plot(get(h,'CurrentAxes'), bandname,spectral);   
   if range(spectral(:)) <= 1 
        set(get(h,'CurrentAxes'),'YLim',[0 1]);
   end
  % title(handles.axes_spec,'spectral profile');
   i = i + 1;
   if (i == num+1)
       break;
   end
   
end



% --------------------------------------------------------------------
function ToolOpen_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to ToolOpen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

currentpath = cd();
[filename, pathname] = uigetfile({'*.hdr;*.dat;*.raw;*.mat','Hyper Files (*.hdr,*.dat,*.raw,*.mat)'},'Load Hyperspectral File');
if (filename==0) % cancel pressed
    return;
end
cd (pathname);
if strcmp(filename(end-3:end), '.mat')
    datacube=importdata(filename);
    if isstruct(datacube)
        datacube=datacube.ref;
        
        if size(datacube,3) == 31
            bandname = (420:10:720)';
        end 
    else 
        switch size(datacube,3)
            case 31
                bandname = (410:10:710)';
        %else size(datacube,3) == 56 need to be fixed, because I don't know
        %the first bandname
            case 33
                bandname = (400:10:720)';
            case 41
                bandname = (600:10:1000)';
            case 51
                bandname = (500:10:1000)';
            case 61 
                bandname = (400:10:1000)';
            case 65
                bandname = (450:10:1090)';
            case 148
                bandname = (linspace(415,950,148))';
            otherwise
                bandname = (1:1:size(datacube,3))';
        end
    end
%   normalization will be done in meau
%     if max(datacube(:)) ~= 1 && size(datacube,3) ~= 255
%         datacube = normalise(datacube,'percent', 0.999);
%     else
%         datacube = normalise(datacube,'percent', 1);
%     end
    description = 'online database';
else
    [datacube, bandname, description] = Load_Spec(filename);
%      darkFrame = importdata('darkFrame.mat');
%      slice = mean(darkFrame, 3);
%      for mm = 1:size(darkFrame,3);
%          darkFrame(:,:,mm) = slice;
%      end
%      datacube = datacube - darkFrame;
%    %when the images become clear, let's have a try without no resize.
%     datacube = normalise(datacube,'percent', 1);
    if handles.version == 2
        datacube = datacube(:,:,end-40:end);
        bandname = bandname(end-40:end);
    end
  %  handles.datacube = d;
end
cd (currentpath);
handles.datacube = datacube;
handles.originalDatacube = datacube; % back up
handles.bandname = bandname;
numofBand = length(bandname);
midBand = round(numofBand/2);
interval = bandname(2) - bandname(1);
slidermin = bandname(1);
slidermax = bandname(end);
sliderstep = [interval interval] / (slidermax - slidermin);
set (handles.TextInfo, 'String', [filename ' ' description]);
set (handles.SliderWavelength,'Min',slidermin);
set (handles.SliderWavelength,'Max',slidermax);
set (handles.SliderWavelength,'SliderStep',sliderstep);
set (handles.SliderWavelength,'Value',bandname(midBand));
set (handles.EditWavelength, 'String', bandname(midBand));
slice = squeeze(datacube(:,:,midBand));
RGB(:,:,1) = slice;
RGB(:,:,2) = slice;
RGB(:,:,3) = slice;
% if  isempty(find(bandname == 500, 1))
%     RGB(:,:,1) = slice;
%     RGB(:,:,2) = slice;
%     RGB(:,:,3) = slice;
% else   
%     RGB(:,:,1) = squeeze(handles.datacube(:,:,floor((650-bandname(1))/10+1)));
%     RGB(:,:,2) = squeeze(handles.datacube(:,:,floor((550-bandname(1))/10+1)));
%     RGB(:,:,3) = squeeze(handles.datacube(:,:,floor((500-bandname(1))/10+1)));
% end
handles.RGB = RGB;
axes(handles.axes1); cla; imshow(slice, []);
axes(handles.axes_spec); cla;
set(handles.axes_spec, 'Visible', 'off');
guidata(hObject, handles)


% --- Executes on button press in ButtonCalibrate.
function ButtonCalibrate_Callback(hObject, eventdata, handles)
% hObject    handle to ButtonCalibrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.axes_spec,'Visible','On');
datacube = double(handles.datacube);
bandname = handles.bandname;
axes(handles.axes1);
rect = getrect(handles.axes1);
roi=datacube(round(rect(2)):round(rect(2)+rect(4)),round(rect(1)):round(rect(1)+rect(3)),:);      
spectral = squeeze(mean(mean(roi,1),2));  
plot(handles.axes_spec,bandname,spectral,'b'); 
title(handles.axes_spec,'spectral profile');
for i = 1:length(bandname)
   datacube(:,:,i) = datacube(:,:,i)/ spectral(i);
end
handles.datacube = datacube;
guidata(hObject, handles)


% --- Executes when user attempts to close MainFigure.
function MainFigure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to MainFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
close all


% --------------------------------------------------------------------
function uipushtool4_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[FileName, path] = uiputfile({'*.jpg;*.tif;*.png;*.gif','All Image Files';...
          '*.*','All Files' },'Save Image');
currentpath = cd();  
cd(path);
img = getimage(handles.axes1);
imwrite(img,FileName);
cd(currentpath);


% --- Executes on button press in RadioOverlaid.
function RadioOverlaid_Callback(hObject, eventdata, handles)
% hObject    handle to RadioOverlaid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RadioOverlaid
set(handles.RadioGray,'value',0);
set(handles.RadioColor,'value',0);
slice = sum(handles.datacube, 3);
slice = slice/length(handles.bandname);
axes(handles.axes1); cla; imshow(slice,[]);


% --------------------------------------------------------------------
function Refine_Callback(hObject, eventdata, handles)
% hObject    handle to Refine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

focuslevel = handles.focus;
qualitythresh =  min(focuslevel)*2;
goodnum = length(find(focuslevel > qualitythresh));
badnum = length(focuslevel) - goodnum;
[m, n, ~] = size(handles.datacube);
datacube = zeros(m, n, goodnum);
bandname = zeros(goodnum , 1);
j = 1;
for i = 1: length(handles.bandname)
    slice = squeeze(handles.datacube(:,:,i));  
    if focuslevel(i) > qualitythresh;
        datacube(:,:,j) = slice;
        bandname(j) = handles.bandname(i);
        j = j + 1;
    end
end
handles.datacube = datacube;
handles.bandname = bandname;

msgbox(sprintf('%d %s', badnum, 'bad frames have been removed')); 
interval = bandname(2) - bandname(1);
slidermin = bandname(1);
slidermax = bandname(end);
sliderstep = [interval interval] / (slidermax - slidermin);
set (handles.SliderWavelength,'Min',slidermin);
set (handles.SliderWavelength,'Max',slidermax);
set (handles.SliderWavelength,'SliderStep',sliderstep);
guidata(hObject, handles)

    
    
% --------------------------------------------------------------------
function Saveas_Callback(hObject, eventdata, handles)
% hObject    handle to Saveas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName, Path] = uiputfile({'*.mat';'*.dat'},'Save data cube');
currentpath = cd();
if FileName == 0
    return
end

datacube = handles.datacube;
if range(datacube(:)) > 1 
    datacube = normalise(datacube, 'p', 0.999);
end
datacube = datacube*255;
datacube = uint8(datacube);

if strcmp(FileName(end-3:end),'.mat')
    cd (Path);
    save(FileName, 'datacube');
end
cd (currentpath);
msgbox('new data cube has been saved.','save file');


function [outdata,mind,maxd] = normalise(data, p2, p3)
indata = double(data);
percent = p3;
ndata = numel(indata);
[val,~] = sort(indata(:));
upos = round(ndata*percent);
maxd = val(upos);
mind = min(indata(:));
outdata = (indata-double(mind)*ones(size(indata))) / (maxd-mind);
outdata(find(outdata(:)>1)) = 1;

%--------------------------------------------------------------------
function ToolSegment_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to ToolSegment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
addpath('C:\Users\s2882161\Documents\MATLAB\libsvm');
addpath('C:\Users\s2882161\Documents\MATLAB\multimodal');
datacube = handles.datacube;
bandname = handles.bandname;
kmeansInitial = importdata('kmeansInitial.mat');
l = 5;
[m, n, b] = size(datacube);
img = zeros(m*n,1);
d = reshape(datacube,[m*n, b]);
%kmeansInitial = [plant; frame; white; base; background];
[idx,ctrs] = kmeans(d,l,'Distance','cosine', 'start', kmeansInitial);
%[idx,ctrs] = kmeans(d,l, 'start', kmeansInitial);
for i = 1:l
    img(idx==i) = i;
end
img = reshape(img, [m n]);
axes(handles.axes1),cla;
imagesc(img);
colormap(jet);


d(idx == 3,:) = 0;
d(idx == 4,:) = 0;
d(idx == 5,:) = 0;

svmsamples = importdata('svmsamples.mat');
l = 2;
samplenum = 20;
img = zeros(m*n,1);
label_instance = [zeros(samplenum,1); ones(samplenum,1); ones(samplenum,1)*2];
instance = [zeros(samplenum,41); svmsamples.plant; svmsamples.frame];
model = svmtrain(label_instance, instance, '-s 1');
[predicted_label] = svmpredict(zeros(m*n,1),d, model);
for i = 1:l
    img(predicted_label==i) = i;
end
img = reshape(img, [m n]);
axes(handles.axes1),cla;
imagesc(img);
d(predicted_label == 0,:) = 0;
d(predicted_label == 2,:) = 0;

datacube = reshape(d,[m, n, b]);

handles.datacube = datacube; %
guidata(hObject, handles);




% --- Executes on button press in ButtonImadjust.
function ButtonImadjust_Callback(hObject, eventdata, handles)
% hObject    handle to ButtonImadjust (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
slice = getimage(handles.axes1);
slice = double(slice);
minv = min(slice(:));
maxv = max(slice(:));
slice=(slice-minv)./(maxv-minv);
slice = imadjust(slice);
axes(handles.axes1),cla;
imshow(slice);
guidata(hObject, handles);


% --------------------------------------------------------------------
function MenuOutput_Callback(hObject, eventdata, handles)
% hObject    handle to MenuOutput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[foldername, path] = uiputfile({ '*.*','All Files' },'Output images into a folder');
currentpath = cd();  
cd(path);
mkdir(foldername)

datacube = handles.datacube;
bandname = handles.bandname; 
if range(datacube(:)) > 1 
    datacube = normalise(datacube, 'p', 0.999);
end
datacube = datacube*255;
datacube = uint8(datacube);
[~, ~, b] = size(datacube);
for i = 1:b
    img = squeeze(datacube(:,:,i));
    img = imadjust(img);
    img = uint8(img);
    imgname = fullfile(foldername, [num2str(bandname(i)), '.jpg']);
    imwrite(img,imgname);
end    
cd(currentpath); 

% --------------------------------------------------------------------
function MenuOpen_Callback(hObject, eventdata, handles)
% hObject    handle to MenuOpen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ToolOpen_ClickedCallback(hObject, eventdata, handles)

% --------------------------------------------------------------------



% --------------------------------------------------------------------
function Calibration_Callback(hObject, eventdata, handles)
% hObject    handle to Calibration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function DarkCalibrate_Callback(hObject, eventdata, handles)
% hObject    handle to DarkCalibrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

currentpath = cd();
[filename, pathname] = uigetfile({'*.hdr;*.dat','Hyper Files (*.hdr,*.dat)'},'Load Dark Frame');
if (filename==0) % cancel pressed
    return;
end
cd (pathname);
[darkFrame, ~, ~] = Load_Spec(filename);
cd (currentpath);
slice = mean(darkFrame, 3);
for mm = 1:size(darkFrame,3);
    darkFrame(:,:,mm) = slice;
end
handles.darkFrame = darkFrame;
guidata(hObject, handles);
msgbox('dark frame loaded');



% --------------------------------------------------------------------
function WhiteCalibrate_Callback(hObject, eventdata, handles)
% hObject    handle to WhiteCalibrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.axes_spec,'Visible','On');
datacube = handles.datacube;
bandname = handles.bandname;
%specify the area of spectralon
axes(handles.axes1);
rect = getrect(handles.axes1);
roi = datacube(round(rect(2)):round(rect(2)+rect(4)),round(rect(1)):round(rect(1)+rect(3)),:);      
whiteReference = squeeze(mean(mean(roi,1),2));  
plot(handles.axes_spec,bandname,whiteReference,'b'); 
title(handles.axes_spec,'spectral profile');
handles.rect = rect;
guidata(hObject, handles);


% --------------------------------------------------------------------
function Process_Callback(hObject, eventdata, handles)
% hObject    handle to Process (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

datacube = double(handles.datacube);
bandname = handles.bandname;
% process the white and dark calibration

if isfield(handles, 'darkFrame')
    darkFrame = double(handles.darkFrame);   
else
    disp('Dark frame does not exist.');
    darkFrame = zeros(size(datacube));
end
Rdatacube = datacube - darkFrame;
if  isfield(handles, 'rect')
    rect = handles.rect;
    whiteArea = datacube(round(rect(2)):round(rect(2)+rect(4)),round(rect(1)):round(rect(1)+rect(3)),:); 
    darkArea = darkFrame(round(rect(2)):round(rect(2)+rect(4)),round(rect(1)):round(rect(1)+rect(3)),:);
    RwhiteArea =  whiteArea - darkArea;
    %make sure they are above 0
    Dmin = min(Rdatacube(:));
    Wmin = min(RwhiteArea(:));
    minimum = min(Dmin, Wmin);
    if minimum < 0
        NRdatacube = Rdatacube + abs(minimum);
        NRwhiteArea = RwhiteArea + abs(minimum);
        %NRdatacube = Rdatacube + abs(Dmin);
        %NRwhiteArea = RwhiteArea + abs(Wmin);
    else 
        NRdatacube = Rdatacube;
        NRwhiteArea = RwhiteArea;
    end
    whiteReference = squeeze(mean(mean(NRwhiteArea,1),2));
else
    disp('Spectralon is not used.');
    NRdatacube = Rdatacube;
    whiteReference = ones(1,size(datacube,3)); 
end

for i = 1:length(bandname)
   datacube(:,:,i) = NRdatacube(:,:,i)/ whiteReference(i);
end
datacube = normalise(datacube,'percent', 0.999);
handles.datacube = datacube;
guidata(hObject, handles);
SliderWavelength_Callback(hObject, eventdata, handles);


% --------------------------------------------------------------------
function Normalise_Callback(hObject, eventdata, handles)
% hObject    handle to Normalise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
datacube = normalise(handles.datacube,'percent', 0.999);
handles.datacube = datacube;
guidata(hObject, handles);


% --------------------------------------------------------------------
function OutputAsWhole_Callback(hObject, eventdata, handles)
% hObject    handle to OutputAsWhole (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[foldername, path] = uiputfile({ '*.*','All Files' },'Output images into a folder');
currentpath = cd();  
cd(path);
mkdir(foldername)
datacube = handles.datacube;
bandname = handles.bandname; 
if range(datacube(:)) <= 1 
    datacube = normalise(datacube, 'p', 0.999);
end
datacube = datacube * 255;
datacube = uint8(datacube);
[~, ~, b] = size(datacube);
for i = 1:b
    img = squeeze(datacube(:,:,i));
    imgname = fullfile(foldername, [num2str(bandname(i)), '.jpg']);
    imwrite(img,imgname);
end    
cd(currentpath); 


% --- Executes on button press in ButtonClassify.
function ButtonClassify_Callback(hObject, eventdata, handles)
% hObject    handle to ButtonClassify (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
datacube = handles.datacube;
bandname = handles.bandname;
[m, n, b] = size(datacube);
rect = getrect(handles.axes1);
roi = datacube(round(rect(2)):round(rect(2)+rect(4)),round(rect(1)):round(rect(1)+rect(3)),:);      
spectral = squeeze(mean(mean(roi,1),2));
plot(handles.axes_spec, bandname, spectral);   
tempData = reshape(datacube, [m*n, b]);
tempData = double(tempData');
rho = corr(tempData, spectral);
rho(rho>0.9) = 0;
img = reshape(rho,[m, n]);
figure, imshow(img, []);

% rho = corr(data', spectral');




% --- Executes on button press in ButtonDenoise.
function ButtonDenoise_Callback(hObject, eventdata, handles)
% hObject    handle to ButtonDenoise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
method = get(handles.PopupmenuDenoise, 'Value');
datacube = handles.datacube;
bandname = handles.bandname;
[m, n, b] = size(datacube);
switch method
    case 1 %'Gaussian'
        h = fspecial('gaussian');
        denoisedData = imfilter(datacube,h);
    case 2 %'Mean'
        h = fspecial('average');
        denoisedData = imfilter(datacube,h);
    case 3 %'Meddian'
        for i = 1:b
            slice = datacube(:,:,i);
            denoisedData(:,:,i) = medfilt2(slice);
        end   
    case 4 %'NMF'
        commandwindow;
        denoisedData = HSI_denoising(datacube);
        openfig('View_Spec.fig', 'reuse');
    case 5 %'Original'
        denoisedData = handles.originalDatacube;
end
handles.datacube = denoisedData;
guidata(hObject, handles);
SliderWavelength_Callback(hObject, eventdata, handles);





% --- Executes on selection change in PopupmenuDenoise.
function PopupmenuDenoise_Callback(hObject, eventdata, handles)
% hObject    handle to PopupmenuDenoise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PopupmenuDenoise contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PopupmenuDenoise


% --- Executes during object creation, after setting all properties.
function PopupmenuDenoise_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PopupmenuDenoise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
