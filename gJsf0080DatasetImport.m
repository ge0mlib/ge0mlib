function [JsfHead,Head,Data]=gJsf0080DatasetImport(fName,tmpName,JsfHead,Ch,SubCh,Head,Data,FieldKP,NavS,NavP,PtsFileName,varargin)
%Add jsf-files for Message Type 0080 (Sonar Data Message) from file-list or folder to Dataset.
%function [JsfHead,Head,Data]=gJsf0080DatasetImport(fName,tmpName,JsfHead,Ch,SubCh,Head,Data,FieldKP,NavS,NavP,PtsFileName,varargin), where
%fName- list with file's names or folder name with jsf (Message Type 0080 - Sonar Data Message) will be loaded;
%tmpName- folder name for temporary files saving; if isempty, than Data will be empty;
%JsfHead- input JsfHead(1..n) structure (can be empty);
%SubCh- sub channel number;
%Ch- channel number;
%Head-  input Head(1..n) structure (can be empty);
%Data- input cells with Data-matrix or temporary file names;
%FieldKP- the name of Kp-field; there are PingNumber or KilometerPipe (if exist);
%NavS- sensor's navigation structure (see gNavCoord2Coord) for coordinates transformation;
%NavP- project's navigation structure (see gNavCoord2Coord) for coordinates transformation;
%PtsFileName- pts file for WaterDepth field calculation ('Xyz2Triang' method);
%varargin{1}- if exist, then Head.CoordinateUnits(:)=varargin{1};
%[JsfHead,Head,Data]- output variables with added data from files;
%Additional fields:
%JsfHead(n).fNameTmp- name of temporary file with Data matrix;
%GpsDay,GpsTime,GpsE,GpsN,GpsH- fields created by function gJsfDTEN; WaterDepth- calculated using data from PtsFileName.
%Example:
%NavS=struct('TargCode',2);NavP=struct('EllipParam',[6378137 0.081819190842],'ProjParam',[0 142 0.9996 500000 0],'ProjForvFunc','gNavGeog2ProjUtm','ProjRevFunc','gNavProjUtm2Geog','TargCode',6);
%[JsfHead,Head,Data]=gJsf0080DatasetImport('c:\jsf80in\','c:\jsf80in\tmp\',JsfHead,0,20,Head,Data,'PingNumber',NavS,NavP,[],0);
%[JsfHead,Head,Data]=gJsf0080DatasetImport('c:\jsf80in\','c:\jsf80in\tmp\',[],0,20,[],[],'PingNumber',[],[],[]);

if (size(fName,1)==1)&&(fName(end)=='\'),dz=dir(fName);dz([dz.isdir])=[];fName=[repmat(fName,length(dz),1) char(dz.name)];fName=sortrows(fName);end;
Len=size(fName,1);
if isempty(JsfHead),Z=0;clear('JsfHead','Head');Data=cell(1,Len); else Z=length(JsfHead);end;
if ~isempty(PtsFileName), bt=dlmread(PtsFileName);btt=scatteredInterpolant(bt(:,1),bt(:,2),bt(:,3),'linear');end;
for nn=(1+Z):(Len+Z),
    fNameN=deblank(fName(nn-Z,:));disp(fNameN);
    JsfHead0=gJsfHeaderRead(fNameN,1);[Head0,Data0]=gJsf0080Read(JsfHead0,Ch,SubCh);
    if ~isempty(varargin),JsfHead0.CoordinateUnits=varargin{1};end;
    Head0=gJsfDTEN(Head0,FieldKP,NavS,NavP);if ~isempty(PtsFileName),Head0.WaterDepth=btt(Head0.GpsE,Head0.GpsN);end;Head(nn)=Head0;
    L1=find(fNameN=='\');L2=find(fNameN=='.');
    if isempty(tmpName), JsfHead0.fNameTmp=[];Data{nn}='';
    else JsfHead0.fNameTmp=[tmpName fNameN(L1(end)+1:L2(end)) 'jsf0080_tmp'];gDataSave(JsfHead0.fNameTmp,Data0);Data{nn}=JsfHead0.fNameTmp;end;
    JsfHead(nn)=JsfHead0;
end;

%mail@ge0mlib.com 17/02/2020