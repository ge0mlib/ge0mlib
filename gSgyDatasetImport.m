function [SgyHead,Head,Data]=gSgyDatasetImport(fName,tmpName,SgyHead,Head,Data,FieldKP,FieldX,FieldY,NavS,NavP,CoordinateUnits,SourceGroupScalar)
%Add Sgy files from file-list or folder to Dataset.
%function [SgyHead,Head,Data]=gSgyDatasetImport(fName,tmpName,SgyHead,Head,Data,FieldX,FieldY,NavS,NavP,PtsFileName,varargin), where
%fName- list with file's names or folder name with sey will be loaded;
%tmpName- folder name for temporary files saving; if isempty, than Data will be empty;
%SgyHead- input SgyHead(1..n) structure (can be empty);
%Head-  input Head(1..n) structure (can be empty);
%Data- input cells with Data-matrix or temporary file names;
%FieldKP- the name of Kp-field; there are TraceSequenceLine,TraceSequenceFile,FieldRecord,EnergySourcePoint;
%FieldX,FieldY- the names of X and Y fields; there are SourceX, SourceY, GroupX, GroupY, cdpX, cdpY;
%NavS- sensor's navigation structure (see gNavCoord2Coord) for coordinates transformation;
%NavP- project's navigation structure (see gNavCoord2Coord) for coordinates transformation;
%CoordinateUnits- forced value for Head.CoordinateUnits field: 1-cartesian meters;2-geographic seconds;3-geographic degree;4-geographic DMS; if empty, than Head.CoordinateUnits(:)=Head.CoordinateUnits(1);
%SourceGroupScalar- forced value for Head.SourceGroupScalar (-100,-10,-1,1,10,100,etc); if empty, than no forced changes;
%[SgyHead,Head,Data]- output variables with added data from files;
%Additional fields:
%SgyHead(n).fNameTmp- name of temporary file with Data matrix;
%GpsDay,GpsTime,GpsE,GpsN,GpsH- fields created by function gSgyDTEN;
%WaterDepth- calculated using data from PtsFileName.
%Example:
%NavS=struct('TargCode',2);NavP=struct('EllipParam',[6378137 0.081819190842],'ProjParam',[0 142 0.9996 500000 0],'ProjForvFunc','gNavGeog2ProjUtm','ProjRevFunc','gNavProjUtm2Geog','TargCode',6);
%[SgyHead,Head,Data]=gSgyDatasetImport('c:\sgyin\','c:\sgyin\tmp\',SgyHead,Head,Data,'FieldRecord','SourceX','SourceY',NavS,NavP,[],-100);
%[SgyHead,Head,Data]=gSgyDatasetImport('c:\sgyin\','c:\sgyin\tmp\',[],[],[],'TraceSequenceFile','GroupX','GroupY',[],[],1,-100);

if (size(fName,1)==1)&&(fName(end)=='\'), dz=dir(fName);dz([dz.isdir])=[];fName=[repmat(fName,length(dz),1) char(dz.name)];fName=sortrows(fName);end;
Len=size(fName,1);
if isempty(SgyHead), Z=0;clear('SgyHead','Head');Data=cell(1,Len); else Z=length(SgyHead);end;
for nn=(1+Z):(Len+Z),
    fNameN=deblank(fName(nn-Z,:));disp(fNameN);
    [SgyHead0,Head0,Data0]=gSgyRead(fNameN,'',[]);
    if ~isempty(CoordinateUnits),Head0.CoordinateUnits(:)=CoordinateUnits;end;
    if ~isempty(CoordinateUnits),Head0.SourceGroupScalar(:)=SourceGroupScalar;end;
    Head(nn)=gSgyDTEN(Head0,FieldKP,FieldX,FieldY,NavS,NavP,CoordinateUnits,SourceGroupScalar);
    L1=find(fNameN=='\');L2=find(fNameN=='.');
    if isempty(tmpName), SgyHead0.fNameTmp=[];Data{nn}='';
    else SgyHead0.fNameTmp=[tmpName fNameN(L1(end)+1:L2(end)) 'sgy_tmp'];gDataSave(SgyHead0.fNameTmp,Data0);Data{nn}=SgyHead0.fNameTmp;end;
    SgyHead(nn)=SgyHead0;
end;

%mail@ge0mlib.com 04/08/2020