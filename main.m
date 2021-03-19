%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Script for determining the local fibre volume content
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load images. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data.buildingDir = uigetdir();
data.imagecontainer = imageDatastore(data.buildingDir);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Pre-definitions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data.color=colormap(jet); 
data.d_fibre = [5 9];               % Range Fibre diameter in um
data.scalefactor = 0.08702;         % Scale-faktor of Magnification lens (um/Px)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Select ROI of Images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Preallocate the sizes
data.mask=cell(1,numel(data.imagecontainer.Files));
data.Images_temp=cell(1,numel(data.imagecontainer.Files));
% Loop for each image
 for i=1:numel(data.imagecontainer.Files)
I=readimage(data.imagecontainer,i);
% Convert to grayscale 
if size(I,3)==3
    I=rgb2gray(I);
else
end
%% display current Image
imshow(I)
sprintf('Image %d of %d',i,numel(data.imagecontainer.Files))
% get user input
ROI = impoly;
% create mask
mask = createMask(ROI);
% Mask the image.
I_mask = bsxfun(@times, I, cast(mask,class(I)));
% Pre-processing
background = imopen(I_mask,strel('disk',50));
I_mask=I_mask-background;

% save Images and Mask
data.masks{i}=mask;
data.Images_temp{i}=I_mask;
close all
figure
imshow(I_mask)
 end
sprintf('END: Image Pre-Processing') 
clear i mask background ROI I I_mask ans

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Hough Circle Tranform
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:numel(data.imagecontainer.Files)
    clear delaunay centers radii
    sprintf('Start to analyse Image %d',i)

Str = erase(data.imagecontainer.Files{i},[ data.buildingDir '\']);
%% Hough Circle and delete unnecessary Circles
[ ~, ~, centers_new, radii_new,~ ] = ...
    FVG_houghcirc( data.Images_temp{i}, data.d_fibre, data.scalefactor );
sprintf('End Hough Image %d',i)

results.centers_new{i}=centers_new;
results.radii_new{i}=radii_new;

if ~isempty(centers_new)
    figure,imshow(readimage(data.imagecontainer,i)),hold on,
    viscircles(centers_new, radii_new,'EdgeColor','white','linewidth',.5); 
    sprintf('End to analyse Image %d',i)
else
    error('no fibres found')
end
end

clear ceners centers_new radii radii_new Str i index_new ans

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Delaunay Triangulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 for n=1:numel(data.imagecontainer.Files)

Image=readimage(data.imagecontainer,n);
    
Str = erase(data.imagecontainer.Files{n},[ data.buildingDir '\']);  
    
%% local FVG-estimate with Delaunay Triangulation
[ results.FVG{n}, results.tri{n}, results.index{n} ] = FVG_delaunay( Image, results.centers_new{n}, results.radii_new{n}, data.color,Str);
sprintf('End to Triangulation Image %d',n)


clear FVG Str Image centers_new radii_new index_new
end



clear n ans

