function  varargout = subregionSpec( data, r, c, varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if ischar(data) 
    datacube = importdata(data);
else datacube = data;
end
[m, n, b] = size(datacube);
indR = round(linspace(1,m,r+1));
indC = round(linspace(1,n,c+1));
regionsSpec = zeros(r*c,b);
k = 1;
if isempty(varargin)
    if b == 61
        band = 400:10:400+10*(b-1);
    elseif b == 31
        band = 410:10:710;
    else band = 600:10:1000;
        
    end
else
    band = varargin{1};
end
figure,
hold all;
for i = 1:r
    for j = 1:c
        if m == r
            region = datacube(indR(i),indC(j),:);
        else
            region = datacube(indR(i):indR(i+1),indC(j):indC(j+1),:);
        end
        regionsSpec(k,:) = squeeze(mean(mean(region,1),2)); 
        plot(band,regionsSpec(k,:));
        k = k + 1;
    end 
end

legend('toggle');
varargout{1} = regionsSpec;


