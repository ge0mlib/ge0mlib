function gShapeXtfDirPoint(shName,fName,SubCh,FieldX,FieldY,NavS,NavP,HNavUnitsForce,fTable,selTable,sFields,ordF)
%Read Segy-headers from folder with *.sgy, read table with data and create Shape file with trackplots as a Lines.
%function gShapeSgyDirPoint(shName,fName,FieldX,FieldY,NavS,NavP,CoordinateUnits,SourceGroupScalar,ChNum,fTable,selTable,sFields,ordF), where
%shName- name of Shape will saved;
%fName- reading file name or files name or folder name with files (last name's symbol must be '\' for folder);
%SubCh- sub channel number (in Xtf-file with SSS data, like to: 0=XTF_HEADER_SONAR (Sidescan data), Num: 4157 [ SubCh: 0, Num: 4157; ChFollow: 2, Num: 4157 ];
%FieldX,FieldY- the names of X and Y fields; there are SourceX, SourceY, GroupX, GroupY, cdpX, cdpY.
%NavS- (see gNavCoord2Coord) navigation datum for Sensor, fields: EllipParam, ProjParam, ProjForvFunc, ProjRevFunc, EllipTransParam, EllipForvTransFunc, EllipRevTransFunc, TargCode.
%   if ~isfield(NavS.EllipTransParam), then transformation Sensor's_Ellipsoid-to-Project's ellipsoid not calculate (fields EllipTransParam, EllipForvTransFunc, EllipRevTransFunc not used).
%NavP- (see gNavCoord2Coord) navigation datum for Project, fields: EllipParam, ProjParam, ProjForvFunc, ProjRevFunc, TargCode.
%   NavP.TargCodes=output_datum_code (see gNavCoord2Coord); there are: 1)sensor planar; 2)sensor geographic; 3)sensor geocentric; 4)project geocentric; 5)project geographic; 6)project planar.
%   if isempty(NavS)&&isempty(NavP), than there is no any coordinate transformation;
%HNavUnitsForce- forced HNavUnits for XtfHead: 0-meters; 3-geographic degree; 5-user defined in gXtfDTEN function; if empty, than no forced changes;
%fTable- the table's file-name; *.csv extension, first row is Fields Names for shape (there must not include space-symbol and has 10 characters length);
%   Each row is correspond to own file (file list is sorted by alphabet);
%selTable- the columns numbers selected in the table (other rows are ignored);
%sFields- the cell dimentsion described additional fields for Shape, calculated when shape created; the format: {'FieldName','command_to_create_field_data',...}
%sField examples:
%{'Equipment','''EdgeTech 4200, 100/400kHz'''} -- create field 'Equipment' with text 'Innomar SES-2000 Med';
%{'IOGP_Code','''IOGP2308'''} -- create field 'IOGP_Code' with text 'IOGP2306';
%{'Day','[num2str(Head.HDay(nn),''%02d'') ''/'' num2str(Head.HMonth(nn),''%02d'') ''/'' num2str(Head.HYear(nn),''%02d'')]','Time','[num2str(Head.HHour(nn),''%02d'') '':'' num2str(Head.HMinute(nn),''%02d'') '':'' num2str(Head.HSecond(nn),''%02d'') ''.'' num2str(Head.HHSeconds(nn),''%02d'')]'} % -- create field 'Day' with text in format 'DD/MM/YY';
%{'Ping','Head.HPingNumber(nn)'} -- create PingNumber numbers for each ping (point);
%ordF- new fields ordering (relatively default created); Plot includes 1..3 fields will not recorded to dbf-file ('Geometry','X','Y').
%Example:
%NavS=struct('TargCode',2);NavP=struct('EllipParam',[6378137 0.081819190842],'ProjParam',[0 142 0.9996 500000 0],'ProjForvFunc','gNavGeog2ProjUtm','ProjRevFunc','gNavProjUtm2Geog','TargCode',6);
%z={'Equipment','''EdgeTech 4200, 100/400kHz''','IOGP_Code','''IOGP2308''','Day','[num2str(Head.HDay(nn),''%02d'') ''/'' num2str(Head.HMonth(nn),''%02d'') ''/'' num2str(Head.HYear(nn),''%02d'')]','Time','[num2str(Head.HHour(nn),''%02d'') '':'' num2str(Head.HMinute(nn),''%02d'') '':'' num2str(Head.HSecond(nn),''%02d'') ''.'' num2str(Head.HHSeconds(nn),''%02d'')]','Ping','Head.HPingNumber(nn)'};
%gShapeXtfDirPoint('d:\202207_GeoXYZ_6\SSS_proc_tack\Bl_point','d:\202207_GeoXYZ_6\SSS_proc_tack\01_Bl_XTF\',0,'HShipXcoordinate','HShipYcoordinate',[],[],[],'d:\202207_GeoXYZ_6\SSS_proc_tack\Bl.csv',1:4,z,[1:3 4 5 6 10 11 12 8 9 7]);

if (size(fName,1)==1)&&(fName(end)=='\'), dz=dir(fName);dz([dz.isdir])=[];fName=[repmat(fName,length(dz),1) char(dz.name)];end;
T=readtable(fTable,'Delimiter',';');
if size(T,1)~=size(fName,1),error('Number table lines must be equal files number');end;SS=table2struct(T(:,selTable));SSf=fieldnames(SS);S=struct('Geometry','Point','X',[],'Y',[]);
nnn=0;
for n=1:size(fName,1),
   fNameN=deblank(fName(n,:));LLL=find(fNameN=='\');disp(fNameN(LLL(end)+1:end));XtfHead=gXtfHeaderRead(fNameN,1);[Head,~]=gXtf000Read(XtfHead,SubCh);
   L=((Head.(FieldX)==0)|(Head.(FieldY)==0)); %check Zeros for X and Y coordinates
   if any(L),
       warning(['Zero coordinates were detected and interpolated; file name >> ' fNameN]);
       kkk=1:length(Head.(FieldX));Head.(FieldX)=interp1(kkk(~L),Head.(FieldX)(~L),kkk,'linear','extrap');Head.(FieldY)=interp1(kkk(~L),Head.(FieldY)(~L),kkk,'linear','extrap');
   end;
   Head=gXtfDTEN(XtfHead,Head,[],FieldX,FieldY,NavS,NavP,HNavUnitsForce,[]);
   for nn=1:numel(Head.GpsE),
       nnn=nnn+1;
       for nk=1:numel(SSf),S(nnn).(SSf{nk})=SS(n).(SSf{nk});end;
       S(nnn).Geometry='Point';S(nnn).X=Head.GpsE(nn);S(nnn).Y=Head.GpsN(nn);
       for nk=1:2:numel(sFields),S(nnn).(sFields{nk})=eval(sFields{nk+1});end;
   end;
end;
if ~isempty(ordF),S=orderfields(S,ordF);end;
dbfspec=makedbfspec(S);shapewrite(S,shName,'DbfSpec',dbfspec);

%mail@ge0mlib.com 11/11/2022