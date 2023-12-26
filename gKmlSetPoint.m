function gKmlSetPoint(fId,B,L,Z,altitudeMode,PlaceName,StyleId,Descript)
%Write to kml-file "Point" tags and data; extrude=0.
%function gKmlSetPoint(fId,B,L,Z,altitudeMode,PlaceName,StyleId,Descript), where
%fId- file identifier;
%B - latilude in degree, one number;
%L - longitude in degree; one number;
%Z - coordinate along Z-axis depend on altitudeMode; if empty, than ignored (clampToGround and clampToSeaFloor mode used);
%altitudeMode - specifies how altitude components in the <coordinates> element are interpreted; there are (1)clampToGround and clampToSeaFloor, (2)relativeToGround and relativeToSeaFloor, (3)absolute
%PlaceName - the name of place;  examples: 'Line002', 28;
%PointId - the name of point;  examples: 'Line002', 28;
%LineStyleId - the linestyle unic identificator (string or number); examples: 'Stl09', 28, 'RedStyle';
%Descript - description in a separate window; examples: 'seismic survey, area B005', '<![CDATA[Multichannel Seismic data <br> <img src="InfoB005.jpg" width=300> <br>]]>'
%Function Example:
%gKmlSetPoint(fId,65.1,141,10,2,'Line023','B1','1234567890');

if isempty(Z),Z=0;end;
if numel(B)>1,warning('B(1) will be used only');end;if numel(L)>1,warning('L(1) will be used only');end;if numel(Z)>1,warning('Z(1) will be used only');end;
tmp=[L(1);B(1);Z(1)];
if isempty(altitudeMode),altitudeMode=1;end;
if isnumeric(altitudeMode),
    switch altitudeMode,
        case 1, altitudeMode='clampToGround';altitudeModeG='clampToSeaFloor';
        case 2, altitudeMode='relativeToGround';altitudeModeG='relativeToSeaFloor';
        case 3, altitudeMode='absolute';altitudeModeG='absolute'; %incorrect altitudeModeG
        otherwise, warning('Incorrect altitudeMode code; code==1 was used');altitudeMode='clampToGround';altitudeModeG='clampToSeaFloor';
    end;
else altitudeModeG=altitudeMode;
end;
if isnumeric(StyleId),StyleId=num2str(StyleId);end;
if isnumeric(PlaceName),PlaceName=num2str(PlaceName);end;
if isnumeric(Descript),Descript=num2str(Descript);end;
fprintf(fId,'	<Placemark>\n');
fprintf(fId,'		<name>');fprintf(fId,PlaceName);fprintf(fId,'</name>\n');
if ~isempty(Descript),
    fprintf(fId,'		<description>');fprintf(fId,Descript);fprintf(fId,'</description>\n');
end;
fprintf(fId,'		<styleUrl>#');fprintf(fId,StyleId);fprintf(fId,'</styleUrl>\n');
fprintf(fId,'		<Point>\n');
fprintf(fId,'			<extrude>0</extrude>\n');
fprintf(fId,'			<altitudeMode>');fprintf(fId,altitudeMode);fprintf(fId,'</altitudeMode>\n');
fprintf(fId,'			<gx:altitudeMode>');fprintf(fId,altitudeModeG);fprintf(fId,'</gx:altitudeMode>\n');
fprintf(fId,'			<coordinates>\n');
fprintf(fId,'				');fprintf(fId,'%0.12f,',tmp(:));fseek(fId,-1,'cof');fprintf(fId, '\n');
fprintf(fId,'			</coordinates>\n');
fprintf(fId,'		</Point>\n');
fprintf(fId,'	</Placemark>\n');

%mail@ge0mlib.com 21/08/2021
