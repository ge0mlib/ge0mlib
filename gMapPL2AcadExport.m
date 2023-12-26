function gMapPL2AcadExport(fName,PL,PLNameAttr,CircleAttr,KPNameAttr,DigitNum,PointsStep,flLayers)
%Export Track-polyline structure to AutoCad script
%function gMapPL2AcadExport(fName,PL,PLNameAttr,CircleAttr,KPNameAttr,DigitNum,PointsStep,flLayers), where
%fName - file or folder name for export; if fName(end)=='\', then each PL write to file [PL(n).PLName '.scr'];
%PL - polyline structure ncludes: PL(n).PLName; PL(n).GpsE; PL(n).GpsN; PL(n).GpsKP(?);
%PLNameAttr=[Size Angle dE dN CircleRadius] - PL(n).PLName text attributes;
%if PLNameAttr=[Size Angle], than dE=0, dN=0;
%if PLNameAttr includes CircleRadius, then draw circle for first polyline's point, using CircleRadius;
%CircleAttr=[Radius DrawModulio] - circles draw attributes for polyline's points;
%if numel(CircleAttr)>2, then gAcadPline is not draw !!!
%KPNameAttr=[Size Angle DrawModulio KPDigitNum] - PL(n).GpsKP text attributes for polyline's points (combine with circles);
%DigitNum - number of digits after floating point for pline/circles;
%PointsStep - step of points for polyline draw (gAcadPline);
%flLayers - each pline to own layer.
%AutoCad coordinates:
%^GpsN
%|
%o--->GpsE
%Example:
%PLXtf=gXtf000Dir2PLRead('c:\temp\SSS\3\','-b',[6378137 0.081819190842621],[0 141 0.9996 500000 0],[],1,1);
%gMapPL2AcadExport('c:\temp\SSS\3\Cad\',PLXtf,[7 0 0 2 3],[5 100],[2 0 500 1],2,1,1);
%PL=gMapPLReadTxt('e:\Lazarev170818.txt',3,'.');
%gMapPL2AcadExport('c:\temp\333.scr',PL,[3 0],[0.3 1],[1 0 500 2],2,1,0);

if isa(fName,'double'), fId=fName;
elseif isa(fName,'char'), if fName(end)~='\',fId=fopen(fName,'w');end;%gAcadZoom(fId,[0 0 0.0001],4);
else error('fName must be filename or dir-name or fId');
end;
for n=1:numel(PL),
    if isa(fName,'char')&&(fName(end)=='\'),fId=fopen([fName '\' PL(n).PLName '.scr'],'w');gAcadZoom(fId,[0 0 0.0001],4);end;
    if flLayers, gAcadLayerMake(fId,PL(n).PLName);end;
    if ~isempty(PLNameAttr),
        if numel(PLNameAttr)==2, PLNameAttr(3:4)=0;end;
        gAcadText(fId,PL(n).GpsE(1)+PLNameAttr(3),PL(n).GpsN(1)+PLNameAttr(4),PLNameAttr(1),PLNameAttr(2),PL(n).PLName,[DigitNum DigitNum]); %scripting PL(n).PLName string
        if numel(PLNameAttr)==5,gAcadCircle(fId,PL(n).GpsE(1),PL(n).GpsN(1),PLNameAttr(5),[DigitNum DigitNum DigitNum]);end; %scripting circle for PLName-point
    end;
    PLz=PL(n);PLz.GpsE=PLz.GpsE(1:PointsStep:end);PLz.GpsN=PLz.GpsN(1:PointsStep:end);
    if (length(PLz.GpsN)~=1)&&(numel(CircleAttr)<3), gAcadPline(fId,PLz.GpsE,PLz.GpsN,[DigitNum DigitNum]);end;
    if ~(isempty(CircleAttr)),L=~mod(1:numel(PLz.GpsE),CircleAttr(2));if ~isempty(L)&&any(L),gAcadCircle(fId,PLz.GpsE(L),PLz.GpsN(L),CircleAttr(1),[DigitNum DigitNum DigitNum]);end;end; %scripting circles for polyline-points
    if isfield(PLz,'GpsKP'),
        PLz.GpsKP=PLz.GpsKP(1:PointsStep:end);
        L=~mod(1:numel(PLz.GpsE),KPNameAttr(3));if ~isempty(L)&&any(L),gAcadText(fId,PLz.GpsE(L),PLz.GpsN(L),KPNameAttr(1),KPNameAttr(2),PLz.GpsKP(L),[DigitNum DigitNum KPNameAttr(4)]);end;  %scripting GpsKP-text for polyline-points
    end;
    if fName(end)=='\',fclose(fId);end;
end;
if isa(fName,'char')&&(fName(end)~='\'),fclose(fId);end;

%mail@ge0mlib.com 13/08/2022