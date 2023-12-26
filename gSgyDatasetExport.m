function gSgyDatasetExport(DirName,SgyHead,Head,Data,FieldKP,FieldX,FieldY,NavS,NavP,CoordinateUnits,SourceGroupScalar)
%Export Sgy-variables from Dataset to files (GpsDay,GpsTime,GpsE,GpsN,GpsH fields are used).
%function gSgyDatasetExport(DirName,SgyHead,Head,Data,NavS,NavP,CoordinateUnits,SourceGroupScalar), where
%DirName- folder for export;
%SgyHead- exported SgyHead(1..n) structure;
%Head-  exported Head(1..n) structure;
%Data- exported Data-cells with matrix or temporary file names;
%FieldKP- the name of Kp-field; there are MessageNum,TraceSequenceLine,TraceSequenceFile,FieldRecord,EnergySourcePoint;
%FieldX,FieldY- the names of X and Y fields; there are SourceX, SourceY, GroupX, GroupY, cdpX, cdpY;
%NavS- sensor's navigation structure (see gNavCoord2Coord) for coordinates transformation;
%NavP- project's navigation structure (see gNavCoord2Coord) for coordinates transformation;
%CoordinateUnits- forced scalar, units code for coordinates (see sgy description); if empty, than value form initial Sgy-file will used;
%SourceGroupScalar- forced scalar, coded multiple for coordinates (see sgy description); if empty, than value form initial Sgy-file will used;
%Additional fields:
%SgyHead(n).fName- name of original file;
%SgyHead(n).fNameTmp- name of temporary file;
%GpsDay,GpsTime,GpsE,GpsN,GpsH- fields created by function gSgyDTEN.
%Example:
%NavS=struct('TargCode',2);NavP=struct('EllipParam',[6378137 0.081819190842],'ProjParam',[0 142 0.9996 500000 0],'ProjForvFunc','gNavGeog2ProjUtm','ProjRevFunc','gNavProjUtm2Geog','TargCode',6);
%gSgyDatasetExport('c:\sgyout\',SgyHead,Head,Data,'TraceSequenceFile','SourceX','SourceY',NavS,NavP,1,-100);
%gSgyDatasetExport('c:\sgyout\',SgyHead,Head,Data,'TraceSequenceFile','GroupX','GroupY',[],[],[],[]);

for nn=1:length(SgyHead),
    Head0=gSgyDTENinv(Head(nn),FieldKP,FieldX,FieldY,NavS,NavP,CoordinateUnits,SourceGroupScalar);
    if all(ischar(Data{nn})),Data0=gDataLoad(Data{nn});else Data0=Data{nn};end;
    L1=find(SgyHead(nn).fName=='\');L2=find(SgyHead(nn).fName=='.');nm=[SgyHead(nn).fName(L1(end)+1:L2(end)) 'sgy'];
    gSgyWrite(SgyHead(nn),Head0,Data0,[DirName '\' nm]);
end;

%mail@ge0mlib.com 04/08/2020