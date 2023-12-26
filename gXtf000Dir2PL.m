function PL=gXtf000Dir2PL(fName,KeyLineDraw,FieldKP,FieldX,FieldY,NavS,NavP,XtfHeadNavUnitsForce)
%Read coordinates form Directory with SSS files (Message Type 000) to PL-structure.
%function PL=gXtf000Dir2PL(fName,KeyLineDraw,FieldKP,FieldX,FieldY,NavS,NavP,XtfHeadNavUnitsForce), where
%fName- reading file name or folder name with files (last name's symbol must be '\');
%keyLineDraw- string key for line drawing: '-r','xb', etc;
%FieldKP- field from Head structure copied to PL(n).GpsKP; if empty, than PL(n).GpsKP=1:length(PL(n).GpsE).
%FieldX,FieldY- the names of X and Y fields; there are Head.HShipYcoordinate,Head.HShipXcoordinate,Head.HSensorYcoordinate,Head.HSensorXcoordinate;
%NavS- (see gNavCoord2Coord) navigation datum for Sensor, fields: EllipParam, ProjParam, ProjForvFunc, ProjRevFunc, EllipTransParam, EllipForvTransFunc, EllipRevTransFunc, TargCode.
%if ~isfield(NavS.EllipTransParam), then transformation Sensor's_Ellipsoid-to-Project's ellipsoid not calculate (fields EllipTransParam, EllipForvTransFunc, EllipRevTransFunc not used).
%NavP- (see gNavCoord2Coord) navigation datum for Project, fields: EllipParam, ProjParam, ProjForvFunc, ProjRevFunc, TargCode.
%if isempty(NavS)&&isempty(NavP)&&isempty(NavPTargCode), than there is no any coordinate transformation;
%XtfHeadNavUnitsForce- forced value for XtfHead.HNavUnits; if empty, than no forced;
%PL- output structure: PL(n).PLName; PL(n).Type; PL(n).KeyLineDraw; PL(n).GpsE; PL(n).GpsN; PL(n).GpsH; PL(n).GpsKP (to GpsKP write ping number in file).
%Used functions: gXtfHeaderRead,gXtf000Read,gNavCoord2Coord.
%Example:
%NavS=struct('TargCode',2);NavP=struct('EllipParam',[6378137 0.081819190842],'ProjParam',[0 142 0.9996 500000 0],'ProjForvFunc','gNavGeog2ProjUtm','ProjRevFunc','gNavProjUtm2Geog','TargCode',6);
%PLXtf=gXtf000Dir2PL('c:\temp\SSS\3\','-b','HPingNumber','HShipYcoordinate','HShipXcoordinate',NavS,NavP,[]);gMapPLDraw(100,PLXtf);axis equal;

if (size(fName,1)==1)&&(fName(end)=='\'), dz=dir(fName);dz([dz.isdir])=[];fName=[repmat(fName,length(dz),1) char(dz.name)];end;
PL(1:size(fName,1))=struct('PLName',[],'Type','SurveyLineXtf','KeyLineDraw',KeyLineDraw,'GpsE',[],'GpsN',[],'GpsZ',[],'GpsKP',[]);
for n=1:size(fName,1),
   fNameN=deblank(fName(n,:));L1=find(fNameN=='\');L2=find(fNameN=='.');disp(fNameN(L1(end)+1:end));
   XtfHead=gXtfHeaderRead(fNameN,1);[Head,~]=gXtf000Read(XtfHead,0);
   L=((Head.(FieldX)==0)|(Head.(FieldY)==0)); %check Zeros for X and Y coordinates
   if any(L),
       warning(['Zero coordinates were detected and interpolated; file name >> ' fNameN]);
       kkk=1:length(Head.(FieldX));Head.X=interp1(kkk(~L),Head.(FieldX)(~L),kkk,'linear','extrap');Head.Y=interp1(kkk(~L),Head.(FieldY)(~L),kkk,'linear','extrap');
   end;
   Head=gXtfDTEN(XtfHead,Head,FieldKP,FieldX,FieldY,NavS,NavP,XtfHeadNavUnitsForce,[]);%convert coordinates
   PL(n).PLName=fNameN(L1(end)+1:L2(end)-1);
   PL(n).GpsE=Head.GpsE;PL(n).GpsN=Head.GpsN;PL(n).GpsH=Head.GpsH;PL(n).GpsKP=Head.GpsKP;
end;

%mail@ge0mlib.com 28/12/2020