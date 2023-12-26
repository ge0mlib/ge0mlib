function Data=gDataLoad(fName)
%Load matrix from file; file format: 1) text 'ge0mlib_Data'; 2) dimension numbers in uint64; 3) dimension values in uint64; 3) matrixes values in float64.
%function Data=gDataLoad(fName), where
%fName- name of file;
%Data- loaded matrix.
%The function used for loading matrixes from tmp-file.
%Example: Data=gDataLoad('c:\temp\123.dat');

[fId,mes]=fopen(fName,'r');if ~isempty(mes),error(['Error gDataLoad:' mes]);end;
id=char(fread(fId,12,'uint8'))';
if ~strcmp(id,'ge0mlib_Data'),error('Error gDataLoad: file saved not with gDataSave.');end;
nsz=fread(fId,1,'uint64');sz=fread(fId,nsz,'uint64')';
Data=fread(fId,prod(sz),'float64');
Data=reshape(Data,sz);
fclose(fId);

%mail@ge0mlib.com 29/10/2020