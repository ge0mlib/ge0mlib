function gSgyJpMatWrite(SgyHead,Head,Data,fName,CompressionRatio)
%Write [SgyHead,Head,Data] in two files: *.mat includes [SgyHead,Head]; *.jp2 includes Data, converted to 16-bits and compressed to Jpeg2000 picture.
%function gSgyJpMatWrite(SgyHead,Head,Data,fName,CompressionRatio), where
%[SgyHead,Head,Data]- Sgy-file components;
%fName- output files names without extension;
%CompressionRatio- the ratio of the input image size to the output compressed size (for Jp2000); greater than or equal to 1.
%Example: gSgyJpMatWrite(SgyHead,Head,Data,'c:\temp\JpExample10',10);

SgyHead.JpMatDataMin=min(min(Data));
SgyHead.JpMatDataBin=(max(max(Data))-SgyHead.JpMatDataMin)./65535;
Data=uint16(round((Data-SgyHead.JpMatDataMin)./SgyHead.JpMatDataBin));
save([fName '.mat'],'SgyHead','Head');
imwrite(Data,[fName '.jp2'],'jp2','CompressionRatio',CompressionRatio);
%imwrite(Data,[fName '.tif'],'tif');


%mail@ge0mlib.com 09/10/2017