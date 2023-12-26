function gDataSave(fName,Data)
%Save matrix from file; file format: 1) text 'ge0mlib_Data'; 2) dimension numbers in uint64; 3) dimension values in uint64; 3) matrixes values in float64.
%function gDataSave(fName,Data)
%fName- name of file;
%Data- saved matrix.
%The function used for saving matrixes to tmp-file.
%Example: gDataSave('c:\temp\123.dat',Data);

sz=size(Data);if isempty(sz),error('Error gDataSave: Data is empty');end;
[fId,mes]=fopen(fName,'w');if ~isempty(mes),error(['Error gDataSave:' mes]);end;
fwrite(fId,uint8('ge0mlib_Data'),'uint8');fwrite(fId,numel(sz),'uint64');fwrite(fId,sz,'uint64');fwrite(fId,Data,'float64');fclose(fId);

%mail@ge0mlib.com 03/08/2020