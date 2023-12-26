function PL=gJsf0080Dir2PL(fName,ChN,SubSys,KeyLineDraw,FieldKP,NavS,NavP,CoordinateUnits)
%Read coordinates form Directory with SSS files (MessageType 0080) to PL-structure.
%function PL=gJsf0080Dir2PL(fName,ChN,SubSys,KeyLineDraw,FieldKP,NavS,NavP,CoordinateUnits), where
%fName - reading file name or files name or folder name with files (last name's symbol must be '\');
%ChN - channel number;
%SubSys - subsystem number;
%keyLineDraw- string key for line drawing: '-r','xb', etc;
%FieldKP- field from Head structure will copied to PL(n).GpsKP; if empty, than PL(n).GpsKP=1:length(PL(n).GpsE).
%NavS - (see gNavCoord2Coord) navigation datum for Sensor, fields: EllipParam, ProjParam, ProjForvFunc, ProjRevFunc, EllipTransParam, EllipForvTransFunc, EllipRevTransFunc, TargCode.
%if ~isfield(NavS.EllipTransParam), then transformation Sensor's_Ellipsoid-to-Project's ellipsoid not calculate (fields EllipTransParam, EllipForvTransFunc, EllipRevTransFunc not used).
%NavP - (see gNavCoord2Coord) navigation datum for Project, fields: EllipParam, ProjParam, ProjForvFunc, ProjRevFunc, TargCode.
%if isempty(NavS)&&isempty(NavP), than there is no any coordinate transformation will applyed;
%CoordinateUnits- forced value for Head.CoordinateUnits field: 1-cartesian meters;2-geographic seconds;3-geographic degree;4-geographic DMS;5-user defined in gJsfDTEN function;
%if isempty(CoordinateUnits) for HMessageType==0080, than CoordinateUnits=Head.CoordinateUnits(1) as a default;
%if isempty(CoordinateUnits) for HMessageType==0086, than "Latitude, Longitude in degrees" are used by default;
%PL- output structure: PL(n).PLName; PL(n).Type; PL(n).KeyLineDraw; PL(n).GpsE; PL(n).GpsN; PL(n).GpsKP (to GpsKP write ping number in file)
%Used functions: gJsfHeaderRead,gJsf0080Read,gJsfDTEN.
%Example:
%NavS=struct('TargCode',2);NavP=struct('EllipParam',[6378137 0.081819190842],'ProjParam',[0 141 0.9996 500000 0],'ProjForvFunc','gNavGeog2ProjUtm','ProjRevFunc','gNavProjUtm2Geog','TargCode',6);
%PLJsf=gJsf0080Dir2PL('c:\temp\SSS\3\',0,21,'-b','PingNumber',NavS,NavP,[]);gMapPLDraw(100,PLJsf);axis equal;

if (size(fName,1)==1)&&(fName(end)=='\'), dz=dir(fName);dz([dz.isdir])=[];fName=[repmat(fName,length(dz),1) char(dz.name)];end;
PL(1:size(fName,1))=struct('PLName',[],'Type','SurveyLineJsf','KeyLineDraw',KeyLineDraw,'GpsE',[],'GpsN',[],'GpsZ',[],'GpsKP',[]);
%if isempty(NavPTargCode), NavPTargCode=NavP.TargCode;end;
for n=1:size(fName,1),
   fNameN=deblank(fName(n,:));LLL=find(fNameN=='\');disp(fNameN(LLL(end)+1:end));
   JsfHead=gJsfHeaderRead(fNameN,0);[Head,~]=gJsf0080Read(JsfHead,ChN,SubSys);
   L=((Head.CoordinateUnits==0)|(Head.X==0)|(Head.Y==0)); %check Zeros for X and Y coordinates, CoordinateUnits
   if any(L),
       warning(['Zero coordinates or CoordinateUnits were detected and interpolated; file name >> ' fNameN]);
       kkk=1:length(Head.X);Head.X=interp1(kkk(~L),Head.X(~L),kkk,'linear','extrap');Head.Y=interp1(kkk(~L),Head.Y(~L),kkk,'linear','extrap');
       nL=find(~L);Head.CoordinateUnits(L)=Head.CoordinateUnits(nL(1));
   end;
   Head=gJsfDTEN(Head,FieldKP,NavS,NavP,CoordinateUnits,[]);%convert coordinates&Time >>> Head.CoordinateUnits // 88-89 Coordinate Units: 1-X,Y in millimeters; 2-Longitude, Latitude in minutes of arc times 10000; 3-X,Y in decimeters; 255-User defined;
   PL(n).PLName=fNameN(LLL(end)+1:end-4);
   PL(n).GpsE=Head.GpsE;PL(n).GpsN=Head.GpsN;PL(n).GpsZ=Head.GpsH;PL(n).GpsKP=Head.GpsKP;
end;

%mail@ge0mlib.com 28/12/2020