function PL=gSgyDir2PL(fName,KeyLineDraw,FieldKP,FieldX,FieldY,NavS,NavP,CoordinateUnits,SourceGroupScalar,ChNum)
%Read coordinates form Directory with *.sgy to PL-structure; coordinates transformation is applied.
%function PL=gSgyDir2PL(fName,KeyLineDraw,FieldKP,FieldX,FieldY,NavS,NavP,CoordinateUnits,SourceGroupScalar,ChNum), where
%fName- reading file name or files name or folder name with files (last name's symbol must be '\');
%keyLineDraw- string key for line drawing: '-r','xb', etc;
%FieldKP- field from Head structure (gFSgyRead function) copied to PL(n).GpsKP; if empty, than PL(n).GpsKP=1:length(PL(n).GpsE).
%FieldX,FieldY- the names of X and Y fields; there are SourceX, SourceY, GroupX, GroupY, cdpX, cdpY.
%NavS- (see gNavCoord2Coord) navigation datum for Sensor, fields: EllipParam, ProjParam, ProjForvFunc, ProjRevFunc, EllipTransParam, EllipForvTransFunc, EllipRevTransFunc, TargCode.
%if ~isfield(NavS.EllipTransParam), then transformation Sensor's_Ellipsoid-to-Project's ellipsoid not calculate (fields EllipTransParam, EllipForvTransFunc, EllipRevTransFunc not used).
%NavP- (see gNavCoord2Coord) navigation datum for Project, fields: EllipParam, ProjParam, ProjForvFunc, ProjRevFunc, TargCode.
%NavP.TargCodes=output_datum_code (see gNavCoord2Coord); there are: 1)sensor planar; 2)sensor geographic; 3)sensor geocentric; 4)project geocentric; 5)project geographic; 6)project planar.
%if isempty(NavS)&&isempty(NavP), than there is no any coordinate transformation;
%CoordinateUnits- forced value for Head.CoordinateUnits field: 1-cartesian meters;2-geographic seconds;3-geographic degree;4-geographic DMS; 255-user defined in gSgyDTEN function;
%if isempty(CoordinateUnits), than CoordinateUnits=Head.CoordinateUnits(1);
%SourceGroupScalar- forced value for Head.SourceGroupScalar (-100,-10,-1,1,10,100,etc); if empty, than no forced changes;
%ChNum- channel number; if ~isempty, then used field Head.TraceNumber to select points from multi-channel streamer;
%PL- output structure: PL(n).PLName; PL(n).Type; PL(n).KeyLineDraw; PL(n).GpsE; PL(n).GpsN; PL(n).GpsKP (to KP write shot number in file)
%Example:
%NavS=struct('TargCode',2);NavP=struct('EllipParam',[6378137 0.081819190842],'ProjParam',[0 142 0.9996 500000 0],'ProjForvFunc','gNavGeog2ProjUtm','ProjRevFunc','gNavProjUtm2Geog','TargCode',6);
%PLSgy=gSgyDir2PL('c:\temp\SSS\3\','-b','TraceSequenceLine','SourceX','SourceY',NavS,NavP,[],[],[]);gMapPLDraw(100,PLSgy);axis equal;

if (size(fName,1)==1)&&(fName(end)=='\'), dz=dir(fName);dz([dz.isdir])=[];fName=[repmat(fName,length(dz),1) char(dz.name)];end;
PL(1:size(fName,1))=struct('PLName',[],'Type','SurveyLineSgy','KeyLineDraw',KeyLineDraw,'GpsE',[],'GpsN',[],'GpsZ',[],'GpsKP',[]);
for n=1:size(fName,1),
   fNameN=deblank(fName(n,:));LLL=find(fNameN=='\');disp(fNameN(LLL(end)+1:end));
   [~,Head,~]=gSgyRead(fNameN,[],[]);
   if ~isempty(ChNum),L=Head.TraceNumber~=ChNum;Head=gFieldsRowSet(Head,length(Head.TraceNumber),L,[]);end; %choose channel number
   L=((Head.(FieldX)==0)|(Head.(FieldY)==0)); %check Zeros for X and Y coordinates
   if any(L),
       warning(['Zero coordinates were detected and interpolated; file name >> ' fNameN]);
       kkk=1:length(Head.(FieldX));Head.(FieldX)=interp1(kkk(~L),Head.(FieldX)(~L),kkk,'linear','extrap');Head.(FieldY)=interp1(kkk(~L),Head.(FieldY)(~L),kkk,'linear','extrap');
   end;
   Head=gSgyDTEN(Head,FieldKP,FieldX,FieldY,NavS,NavP,CoordinateUnits,SourceGroupScalar,[]);
   PL(n).PLName=fNameN(LLL(end)+1:end-4);
   PL(n).GpsE=Head.GpsE;PL(n).GpsN=Head.GpsN;PL(n).GpsZ=Head.GpsH;PL(n).GpsKP=Head.GpsKP;
end;

%mail@ge0mlib.com 28/12/2020