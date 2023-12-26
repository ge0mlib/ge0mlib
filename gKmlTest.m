%script gKmlTest
%Test functions from gKml functions set.

fId=gKmlOpen('c:\temp\112.kml');
gKmlSetStyle(fId,'style01',{'LineStyle',4,'r','ff'},{'BalloonStyle','c','0f','b','0f','<![CDATA[<b><font color="#CC0000" size="-3">$[name]</b> <br> $[description]]]>'});
gKmlSetStyle(fId,'style02',{'LineStyle',4,'r','ff'},{'PolyStyle','b','5f','1','0'});
gKmlSetPoint(fId,64.85,140.34,10,2,'Line023','style01','Point example with style01');
gKmlSetPolyline(fId,[65.1 65.2 65.5],[141 140.5 142],[],1,'Line023','style01','Line examle with style01');
gKmlSetPolygone(fId,[64 64.5 63.5 64],[143 140 139 143],[],1,'Polygone01','style02','Polygone examle with style02',{[64 64 63.8],[140.8 140.25 140.3],[]},{[63.98 63.62 63.78],[140 139.30 140.19],[]});
gKmlClose(fId);

%mail@ge0mlib.com 22/04/2021