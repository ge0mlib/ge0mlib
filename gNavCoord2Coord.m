function [BE,LN,H]=gNavCoord2Coord(BE,LN,H,NavS,NavP,TargCodes)
%Convert coordinates between SensorNavigation datum to ProjectNavigation datum (TargCodes can be used).
%function [BE,LN,H]=gNavCoord2Coord(BE,LN,H,NavS,NavP,TargCodes),where
%BE - row, Latitude on Easting for conversion;
%LN - row, Longitude or Northing for conversion;
%H - row, Height for conversion;
%NavS - navigation datum for Sensor, fields: EllipParam, ProjParam, ProjForvFunc, ProjRevFunc, EllipTransParam, EllipForvTransFunc, EllipRevTransFunc, TargCode.
%if ~isfield(NavS.EllipTransParam), then transformation Sensor's_Ellipsoid-to-Project's ellipsoid not calculate (fields EllipTransParam, EllipForvTransFunc, EllipRevTransFunc not used).
%NavP - navigation datum for Project, fields: EllipParam, ProjParam, ProjForvFunc, ProjRevFunc, TargCode.
%TargCodes=[input_datum_code output_datum_code]; there are: 1)sensor rectangular; 2)sensor geographic; 3)sensor geosentric; 4)project geocentric; 5)project geographic; 6)project rectangular.
%if isempty(TargCodes), than create TargCodes=[NavS.TargCode NavP.TargCode].
%[BE,LN,H] - output data Lat/E, Lon/N, H; rows.
%Example 1 -- Single Ellipsoid; calculate from 2 (sensor geographic) to 6 (project rectangular):
%NavS=struct('TargCode',2);
%NavP=struct('EllipParam',[6378137 0.081819190842],'ProjParam',[0 142 0.9996 500000 0],'ProjForvFunc','gNavGeog2ProjUtm','ProjRevFunc','gNavProjUtm2Geog','TargCode',6);
%[E,N,H]=gNavCoord2Coord(B,L,0,NavS,NavP,[]);
%Example 2 -- Two Ellipsoids; calculate from 2 (sensor geographic) to 6 (project rectangular):
%NavS=struct('EllipParam',[6378137 0.0818191908425],'EllipTransParam',[-43.8 108.8 119.5 1.4 -0.76 0.73 0.54e-6],'EllipForvTransFunc','gNavGeoc2Geoc1032','EllipRevTransFunc','gNavGeoc2Geoc1032inv','TargCode',2);
%NavP=struct('EllipParam',[6378245 0.081813],'ProjParam',[0 51 1 500000 0],'ProjForvFunc','gNavGeog2ProjUtm','ProjRevFunc','gNavProjUtm2Geog','TargCode',6);
%[E,N,H]=gNavCoord2Coord(B,L,zeros(size(B)),NavS,NavP,[]);
%Example 3 -- Single Ellipsoid; calculate from 2 (sensor geographic) to 1 (sensor rectangular):
%NavS=struct('EllipParam',[6378137 0.081819190842],'ProjParam',[0 142 0.9996 500000 0],'ProjForvFunc','gNavGeog2ProjUtm','ProjRevFunc','gNavProjUtm2Geog','TargCode',2);
%NavP=struct('TargCode',6);
%[E,N,H]=gNavCoord2Coord(B,L,0,NavS,NavP,[2 1]);

if isempty(TargCodes), TargCodes(1)=NavS.TargCode;TargCodes(2)=NavP.TargCode;end;
if isempty(H), H=zeros(size(BE));end;
if TargCodes(1)<TargCodes(2),
    for n=TargCodes(1):1:(TargCodes(2)-1),
        switch n,
            case 1, if ~((TargCodes(2)==6)&&~isfield(NavS,'EllipTransParam')&&strcmp(NavS.ProjForvFunc,NavP.ProjForvFunc)&&strcmp(NavS.ProjRevFunc,NavP.ProjRevFunc)&&all(NavS.EllipParam==NavP.EllipParam)&&all(NavS.ProjParam==NavP.ProjParam)),
                    [BE,LN]=feval(NavS.ProjRevFunc,BE,LN,NavS.EllipParam,NavS.ProjParam);end;
            case 2, if isfield(NavS,'EllipTransParam')||(TargCodes(2)==3), [BE,LN,H]=gNavGeog2Geoc(BE,LN,H,NavS.EllipParam);end;
            case 3, if isfield(NavS,'EllipTransParam'), [BE,LN,H]=feval(NavS.EllipForvTransFunc,BE,LN,H,NavS.EllipTransParam);end;
            case 4, if isfield(NavS,'EllipTransParam')||(TargCodes(1)==4),[BE,LN,H]=gNavGeoc2Geog(BE,LN,H,NavP.EllipParam);end;
            case 5, if ~((TargCodes(1)==1)&&~isfield(NavS,'EllipTransParam')&&strcmp(NavS.ProjForvFunc,NavP.ProjForvFunc)&&strcmp(NavS.ProjRevFunc,NavP.ProjRevFunc)&&all(NavS.EllipParam==NavP.EllipParam)&&all(NavS.ProjParam==NavP.ProjParam)),
                    [BE,LN]=feval(NavP.ProjForvFunc,BE,LN,NavP.EllipParam,NavP.ProjParam);end;
        end;
    end;
elseif TargCodes(1)>TargCodes(2),
    for n=(TargCodes(1)-1):-1:TargCodes(2),
        switch n,
            case 5, if ~((TargCodes(2)==1)&&~isfield(NavS,'EllipTransParam')&&strcmp(NavS.ProjForvFunc,NavP.ProjForvFunc)&&strcmp(NavS.ProjRevFunc,NavP.ProjRevFunc)&&all(NavS.EllipParam==NavP.EllipParam)&&all(NavS.ProjParam==NavP.ProjParam)),
                    [BE,LN]=feval(NavP.ProjRevFunc,BE,LN,NavP.EllipParam,NavP.ProjParam);end;
            case 4, if isfield(NavS,'EllipTransParam')||(TargCodes(2)==4), [BE,LN,H]=gNavGeog2Geoc(BE,LN,H,NavP.EllipParam);end;
            case 3, if isfield(NavS,'EllipTransParam'), [BE,LN,H]=feval(NavS.EllipRevTransFunc,BE,LN,H,NavS.EllipTransParam);end;
            case 2, if isfield(NavS,'EllipTransParam')||(TargCodes(1)==3), [BE,LN,H]=gNavGeoc2Geog(BE,LN,H,NavS.EllipParam);end;
            case 1, if ~((TargCodes(1)==6)&&~isfield(NavS,'EllipTransParam')&&strcmp(NavS.ProjForvFunc,NavP.ProjForvFunc)&&strcmp(NavS.ProjRevFunc,NavP.ProjRevFunc)&&all(NavS.EllipParam==NavP.EllipParam)&&all(NavS.ProjParam==NavP.ProjParam)),
                    [BE,LN]=feval(NavS.ProjForvFunc,BE,LN,NavS.EllipParam,NavS.ProjParam);end;
        end;
    end;
end;

%mail@ge0mlib.com 08/02/2019