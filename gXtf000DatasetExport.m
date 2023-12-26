function gXtf000DatasetExport(DirName,XtfHead,Head,Data,FieldKP,FieldX,FieldY,NavS,NavP,HNavUnitsForce)
%Add Xtf-variables from Dataset for Message Type 000 (Sonar Data Message) to files (GpsKP,GpsDay,GpsTime,GpsE,GpsN,GpsH fields are used).
%function gXtf000DatasetExport(DirName,XtfHead,Head,Data,FieldKP,FieldX,FieldY,NavS,NavP,HNavUnitsForce), where
%DirName- folder for export;
%XtfHead- input XtfHead(1..n) structure (can be empty);
%Head-  input Head(1..n) structure (can be empty);
%Data- input cells with Data-matrix or temporary file names;
%FieldKP- the name of Kp-field; there are HMessageNum, HPingNumber
%FieldX,FieldY- the names of X and Y fields; there are Head.HShipYcoordinate,Head.HShipXcoordinate,Head.HSensorYcoordinate,Head.HSensorXcoordinate;
%NavS- sensor's navigation structure (see gNavCoord2Coord) for coordinates transformation;
%NavP- project's navigation structure (see gNavCoord2Coord) for coordinates transformation;
%HNavUnitsForce- forced HNavUnits for XtfHead (if empty, than no forced changes).
%Additional fields:
%XtfHead(n).fNameTmp- name of temporary file with Data matrix;
%GpsKP,GpsDay,GpsTime,GpsE,GpsN,GpsH- fields with time and coordinates used function gXtfDTENinv.
%Example:
%NavS=struct('TargCode',2);NavP=struct('EllipParam',[6378137 0.081819190842],'ProjParam',[0 142 0.9996 500000 0],'ProjForvFunc','gNavGeog2ProjUtm','ProjRevFunc','gNavProjUtm2Geog','TargCode',6);
%[XtfHead,Head,Data]=gXtf000DatasetImport('c:\xtfin\','c:\xtfin\tmp\',XtfHead,0,Head,Data,'HPingNumber','HShipYcoordinate','HShipXcoordinate',NavS,NavP,[],0);
%gXtf000DatasetExport('c:\xtfout\',XtfHead,Head,Data,'HPingNumber','HShipYcoordinate','HShipXcoordinate',NavS,NavP,[]);

for nn=1:length(Head),
    [XtfHead0,Head0]=gXtfDTENinv(XtfHead(nn),Head(nn),FieldKP,FieldX,FieldY,NavS,NavP,HNavUnitsForce);
    if all(ischar(Data{nn})), Data0=gDataLoad(Data{nn});else Data0=Data{nn};end;
    L1=find(XtfHead(nn).fName=='\');L2=find(XtfHead(nn).fName=='.');nm=[XtfHead(nn).fName(L1(end)+1:L2(end)) 'xtf'];
    gXtf000Write(XtfHead0,Head0,Data0,[DirName '\' nm],0);
end;

%mail@ge0mlib.com 03/08/2020