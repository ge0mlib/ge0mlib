function [SgyHead,Head,Data]=gSgyJpMatRead(fName)
%Read [SgyHead,Head,Data] from two files: *.mat includes [SgyHead,Head]; *.jp2 includes Data, converted to 16-bits and compressed to Jpeg2000 picture.
%function [SgyHead,Head,Data]=gSgyJpMatRead(fName), where
%fName- output files names without extension;
%[SgyHead,Head,Data]- Sgy-file components.
%Example: [SgyHead,Head,Data]=gSgyJpMatRead('c:\temp\JpExample10');

load([fName '.mat']);
A=imread([fName '.jp2']);
Data=double(A).*SgyHead.JpMatDataBin+SgyHead.JpMatDataMin;

%mail@ge0mlib.com 09/10/2017