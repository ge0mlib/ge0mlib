function PL=gP1902PL(Head,KeyLineDraw)
%Convert P190 structure to Poly-line structure (can access to PL functions and mapping)
%function PL=gP1902PL(PHead,KeyLineDraw), where
%Head- structure with P190 data.
%keyLineDraw- string key for line drawing: '-r','xb', etc;
%PL- output structure: PL(n).PLName; PL(n).Type; PL(n).KeyLineDraw; PL(n).GpsKP; PL(n).GpsE; PL(n).GpsN; additional fields: PL(n).GpsDay, PL(n).GpsTime, PL(n).WaterDepth.
%Example:
%PL=gP1902PL(PHead,'.-b');gMapPLDraw(100,PLLine,'PLName');axis equal;
%==============Axis========================================
%^y/N
%|
%o--->x/E
%============
%Head structure fields:
%Head.RecordId- Char; Record identification (COL1; A1): 'S'=Centre of Source; 'G'=Receiver Group; 'Q'=Bin Centre; 'A'=Antenna Position; 'T'=Tailbuoy Position; 'C'=Common Mid Point; 'V'=Vessel Reference Point; 'E'=Echo Sounder; 'Z'=Other, defined in H0800.
%Head.LineName- Char; Line name (left justified, including reshoot code) (COL2-13 A12);
%Head.Spare1- Char; Spare (COL14-16 A3);
%Head.VesselId- Char; Vessel ID (COL17 A1);
%Head.SourceId- Char; Source ID (COL18 A1);
%Head.OtherId- Char; Tailbuoy / Other ID (COL19 A1);
%Head.PointNum- Float; Point number (right justified) (COL20-25 A6);
%Head.GpsLat- Float; Latitude in d.m.s. N/S (COL26-35 2(I2), F5.2, A1) or in grads N/S (COL26-35 F9.6, A1);
%Head.GpsLon- Float; Longitude in d.m.s. E/W (COL36-46 I3, I2, F5.2, A1) or in grads E/W (COL36-46 F10.6, A1);
%Head.GpsE- Float; Map grid Easting in metres (COL47-55 F9.1) or in non metric (COL47-55 I9);
%Head.GpsN- Float; Map grid Northing in metres (COL56-64 F9.1) or in non metric (COL56-64 I9);
%Head.WaterDepth- Float; Water depth defined datum defined in H1700 (COL65-70 F6.1) or elevation in non metric (COL65-70 I6);
%Head.GpsDay- Float; Date (date number 1 corresponds to Jan-1-000; the year 0000 is merely a reference point); calculated using Julian Day of year (COL71-73 I3);
%Head.GpsTime- Float; Second in day; calculated using time h.m.s., GMT or as stated in H1000 (COL74-79 3I2);
%Head.Spare2- Char; Spare (COL80 1X);
%"Applicable to 3-D Offshore Surveys" not used.
%============

PL(1:numel(Head))=struct('PLName','','Type','','KeyLineDraw','','GpsKP',[],'GpsE',[],'GpsN',[]);
for n=1:numel(Head),
    PL(n).PLName=Head(n).LineName(:,1)';PL(n).Type='P190';PL(n).KeyLineDraw=KeyLineDraw;
    PL(n).GpsDay=Head(n).GpsDay;PL(n).GpsTime=Head(n).GpsTime;
    PL(n).GpsKP=Head(n).PointNum;PL(n).GpsE=Head(n).GpsE;PL(n).GpsN=Head(n).GpsN;
    PL(n).WaterDepth=Head(n).WaterDepth;
end;

%mail@ge0mlib.ru 08/11/2019