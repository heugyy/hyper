function varargout = Load_Spec( Filename )
%%function varargout =load_spec( filename )
%%varargout contains at least datacube and bandname may be used sometimes.
%%load hyperspectracl ENVI format data, including a raw data file *.dat and header file .hdr
%%auther: Jie Liang
%%data: 25/04/2013
filename = Filename;
offset = 0 ;
l = length(filename);
if filename(l-3) =='.'
   prefix = filename(1:l-4);
end
headername = strcat(prefix,'.hdr');
dataname = strcat(prefix,'.dat');
if 0 == exist(dataname, 'file')
   dataname = strcat(prefix,'.raw');
end
fp = fopen(headername);
if fp == -1
    error('Can''t find the header file!');
end
string = fgets(fp);
while (string ~= -1)
    if (strncmp(string,'description = {',15))
        description = fgets(fp);
    elseif (strncmp(string,'samples',7))
        width= sscanf(string,'samples = %d');
	elseif (strncmp(string,'lines',5))
		height = sscanf(string,'lines = %d');
	elseif (strncmp(string,'bands',5))
		bands = sscanf(string,'bands = %d');
	elseif (strncmp(string,'data type',9))
		datatype = sscanf(string,'data type = %d');
    elseif (strncmp(string,'interleave',10))
        interleave = sscanf(string, 'interleave = %s');
    elseif (strncmpi(string,'wavelength = {',14))
        string = fgets(fp); 
        for i = 1: bands  
            bandname(i,1) = sscanf(string, '%f');
            string = fgets(fp);  
        end
        break;    
    end
string = fgets(fp);
end
fclose(fp);
size = [height, width, bands];
if datatype == 1
    precision = 'uint8=>uint8';
else precision = 'uint16=>uint16';
end
byteorder = 'native';
varargout{1} = multibandread(dataname, size, precision, offset, interleave, byteorder); 
varargout{2} = bandname;
varargout{3} = description(1:end-2);

