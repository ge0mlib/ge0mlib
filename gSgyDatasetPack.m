function Data=gSgyDatasetPack(SgyHead,Data)
%Save Data-matrixes from Data to temporary files (temporary file names are put in Data cells).
%function Data=gSgyDatasetPack(SgyHead,Data), where
%SgyHead- input SgyHead(1..n) structure which include name of temporary file (SgyHead(n).fNameTmp);
%Data- input cells with Data-matrix or temporary file names;
%Data- output cells with temporary file names.
%Example: Data=gSgyDatasetPack(SgyHead,Data);

for nn=1:length(SgyHead),
    if ~ischar(Data{nn}), gDataSave(SgyHead(nn).fNameTmp,Data{nn});Data{nn}=SgyHead(nn).fNameTmp;end;
end;

%mail@ge0mlib.com 30/10/2017