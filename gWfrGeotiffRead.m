function [Head,Data,inf]=gWfrGeotiffRead(fname)
%Read Geotiff-image file and copy values to world-file's structure from tiff's geo-tags.
%function [Head,Data]=gWfrGeotifRead(fname), where
%fname - Geotif-image file name with geo-tags;
%Head - header structure, which includes:
%Head.Color - colormap for palette image;
%Head.Wf - world-file values: [scaleX skewY skewX scaleY left_up_angle_X left_up_angle_Y];
%Head.K=[] - multiple (a) and shift (b) for "Data Original Value" calculation from Color; DataOriginalValue=a*Color+b;
%Head.BgVal=[] – the code of “absent” color (it is means – no data for raster’s pixel with BgVal code);
%Head.ProjName – GeoAsciiParamsTag values;
%Head.ProjInfo – GeoDoubleParamsTag values;
%Head.GeoKeyInfo – GeoKeyDirectoryTag values;
%Data - raster-image data matrix.
%inf - image information ("imread" function’s output).
%Example: [Head,Data,~]=gWfrGeotiffRead('d:\03_Block-3_SSS_Mosaic\Block-3_2.tif');
%==========================
%See tiff tags description in >> https://www.awaresystems.be/imaging/tiff/tifftags.html; https://www.loc.gov/preservation/digital/formats/fdd/fdd000279.shtml
%To extract all geotiff information use: geotiffinfo, geotiffread, geotiffwrite form Mapping Toolbox.
%==========================

[Data,Head.Color]=imread(fname);inf=imfinfo(fname);
%ModelTransformationTag >> Used in interchangeable GeoTIFF files.  This tag is optionally provided for defining exact affine transformations between raster and model space.
%Baseline GeoTIFF files may use this tag or ModelPixelScaleTag, but shall never use both within the same TIFF image directory. This tag may be used to specify the transformation matrix between the raster space (and its dependent pixel-value space) and the (possibly 3D) model space. 
if isfield(inf,'ModelTransformationTag'),error('gWfrGeotifRead function used ModelPixelScaleTag only (the ModelTransformationTag is not used).');end;
%ModelTiepointTag=(...,I,J,K,X,Y,Z,...) >> where (I,J,K) is the point at location (I,J) in raster space with pixel-value K, and (X,Y,Z) is a vector in model space.
%In most cases the model space is only two-dimensional, in which case both K and Z should be set to zero; this third dimension is provided in anticipation of future support for 3D digital elevation models and vertical coordinate systems.
%ModelPixelScaleTag=(ScaleX, ScaleY, ScaleZ) >> where ScaleX and ScaleY give the horizontal and vertical spacing of raster pixels.
%The ScaleZ is primarily used to map the pixel value of a digital elevation model into the correct Z-scale, and so for most other purposes this value should be zero (since most model spaces are 2-D, with Z=0).
if (inf.ModelTiepointTag(3)~=0)||(inf.ModelTiepointTag(6)~=0), error('gWfrGeotifRead function not support 3D digital elevation models and vertical coordinate systems.'); end;
if (inf.ModelTiepointTag(1)==0)&&(inf.ModelTiepointTag(2)==0),
    Head.Wf=[inf.ModelPixelScaleTag(1) 0 0 -inf.ModelPixelScaleTag(2) inf.ModelTiepointTag(4) inf.ModelTiepointTag(5)];
else
    Head.Wf=[inf.ModelPixelScaleTag(1) 0 0 -inf.ModelPixelScaleTag(2) inf.ModelTiepointTag(4)-inf.ModelTiepointTag(1)./ModelPixelScaleTag(1) inf.ModelTiepointTag(5)+inf.ModelTiepointTag(2)./ModelPixelScaleTag(2)];
end;
Head.K=[];Head.BgVal=[];
%GeoAsciiParamsTag >> Used in interchangeable GeoTIFF files. This tag is used to store all of the ASCII valued GeoKeys, referenced by the GeoKeyDirectoryTag. Since keys use offsets into tags, any special comments may be placed at the beginning of this tag.
%For the most part, the only keys that are ASCII valued are "Citation" keys, giving documentation and references for obscure projections, datums, etc. 
if isfield(inf,'GeoAsciiParamsTag'),Head.ProjName=inf.GeoAsciiParamsTag;end;
%GeoDoubleParamsTag >> Used in interchangeable GeoTIFF files. This tag is used to store all of the DOUBLE valued GeoKeys, referenced by the GeoKeyDirectoryTag.
%The meaning of any value of this double array is determined from the GeoKeyDirectoryTag reference pointing to it.FLOAT values should first be converted to DOUBLE and stored here. 
if isfield(inf,'GeoDoubleParamsTag'),Head.ProjInfo=inf.GeoDoubleParamsTag;end;
%GeoKeyDirectoryTag >>  Used in interchangeable GeoTIFF files. This tag is also know as 'ProjectionInfoTag' and 'CoordSystemInfoTag'. This tag may be used to store the GeoKey Directory, which defines and references the "GeoKeys".
if isfield(inf,'GeoKeyDirectoryTag'),Head.GeoKeyInfo=inf.GeoKeyDirectoryTag;end;

%mail@ge0mlib.com 19/06/2018