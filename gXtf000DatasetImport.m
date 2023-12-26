function [XtfHead,Head,Data]=gXtf000DatasetImport(fName,tmpName,XtfHead,SubCh,Head,Data,FieldKP,FieldX,FieldY,NavS,NavP,HNavUnitsForce)
%Add xtf-files for Message Type 000 (Sonar Data Message) from file-list or folder to Dataset.
%function [XtfHead,Head,Data]=gXtf000DatasetImport(fName,tmpName,XtfHead,SubCh,Head,Data,FieldX,FieldY,NavS,NavP,PtsFileName,varargin), where
%fName- list with file's names or folder name with xtf (Message Type 000 - Sonar Data Message) will be loaded;
%tmpName- folder name for temporary files saving; if isempty, than Data will be empty;
%XtfHead- input XtfHead(1..n) structure (can be empty);
%SubCh- sub channel number;
%Head-  input Head(1..n) structure (can be empty);
%Data- input cells with Data-matrix or temporary file names;
%FieldKP- the name of Kp-field; there are HMessageNum, HPingNumber
%FieldX,FieldY- the names of X and Y fields; there are Head.HShipYcoordinate,Head.HShipXcoordinate,Head.HSensorYcoordinate,Head.HSensorXcoordinate;
%NavS- sensor's navigation structure (see gNavCoord2Coord) for coordinates transformation;
%NavP- project's navigation structure (see gNavCoord2Coord) for coordinates transformation;
%HNavUnitsForce- forced HNavUnits for XtfHead (if empty, than no forced changes);
%[XtfHead,Head,Data]- output variables with added data from files;
%Additional fields:
%XtfHead(n).fNameTmp- name of temporary file with Data matrix;
%GpsDay,GpsTime,GpsE,GpsN,GpsH- fields created by function gXtfDTEN.
%Example:
%NavS=struct('TargCode',2);NavP=struct('EllipParam',[6378137 0.081819190842],'ProjParam',[0 142 0.9996 500000 0],'ProjForvFunc','gNavGeog2ProjUtm','ProjRevFunc','gNavProjUtm2Geog','TargCode',6);
%[XtfHead,Head,Data]=gXtf000DatasetImport('c:\xtfin\','c:\xtfin\tmp\',XtfHead,0,Head,Data,'HPingNumber','HShipYcoordinate','HShipXcoordinate',NavS,NavP,0);
%[XtfHead,Head,Data]=gXtf000DatasetImport('c:\xtfin\','c:\xtfin\tmp\',[],0,[],[],'HPingNumber','HSensorYcoordinate','HSensorXcoordinate',[],[],[]);

if (size(fName,1)==1)&&(fName(end)=='\'),dz=dir(fName);dz([dz.isdir])=[];fName=[repmat(fName,length(dz),1) char(dz.name)];fName=sortrows(fName);end;
Len=size(fName,1);
if isempty(XtfHead),Z=0;clear('XtfHead','Head');Data=cell(1,Len); else Z=length(XtfHead);end;
for nn=(1+Z):(Len+Z),
    fNameN=deblank(fName(nn-Z,:));disp(fNameN);
    XtfHead0=gXtfHeaderRead(fNameN,1);[Head0,Data0]=gXtf000Read(XtfHead0,SubCh);
    if ~isempty(HNavUnitsForce),XtfHead0.HNavUnits=HNavUnitsForce;end;
    Head(nn)=gXtfDTEN(XtfHead0,Head0,FieldKP,FieldX,FieldY,NavS,NavP);
    L1=find(fNameN=='\');L2=find(fNameN=='.');
    if isempty(tmpName), XtfHead0.fNameTmp=[];Data{nn}='';
    else XtfHead0.fNameTmp=[tmpName fNameN(L1(end)+1:L2(end)) 'xtf000_tmp'];gDataSave(XtfHead0.fNameTmp,Data0);Data{nn}=XtfHead0.fNameTmp;end;
    XtfHead(nn)=XtfHead0;
end;

%mail@ge0mlib.com 03/08/2020