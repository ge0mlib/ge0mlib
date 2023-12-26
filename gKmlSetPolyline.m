function gKmlSetPolyline(fId,B,L,Z,altitudeMode,PlaceName,LineStyleId,Descript)
%Write to kml-file "Polyline" tags and data; extrude=0, tessellate=1.
%function gKmlSetPolyline(fId,B,L,Z,altitudeMode,PlaceName,LineStyleId,Descript), where
%fId- file identifier;
%B - latilude vector in degree;
%L - longitude vector in degree;
%Z - coordinate vector along Z-axis depend on altitudeMode; if empty, than ignored (clampToGround and clampToSeaFloor mode used);
%altitudeMode - specifies how altitude components in the <coordinates> element are interpreted; there are (1)clampToGround and clampToSeaFloor, (2)relativeToGround and relativeToSeaFloor, (3)absolute
%PlaceName - the name of place (line);  examples: 'Line002', 28;
%LineStyleId - the linestyle unic identificator (string or number); examples: 'Stl09', 28, 'RedStyle';
%Descript - description in a separate window; examples: 'seismic survey, area B005', '<![CDATA[Multichannel Seismic data <br> <img src="InfoB005.jpg" width=300> <br>]]>'
%Function Example:
%gKmlSetPolyline(fId,[65.1 65.2 65.3],[141 141 142],[],1,'Line023','st001','');

if isempty(Z),Z=zeros(size(B));end;
L=L(:)';B=B(:)';Z=Z(:)';tmp=[L;B;Z];
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
if isnumeric(LineStyleId),LineStyleId=num2str(LineStyleId);end;
if isnumeric(PlaceName),PlaceName=num2str(PlaceName);end;
if isnumeric(Descript),Descript=num2str(Descript);end;

fprintf(fId,'	<Placemark>\n');
fprintf(fId,'		<name>');fprintf(fId,PlaceName);fprintf(fId,'</name>\n');
if ~isempty(Descript),
    fprintf(fId,'		<description>');fprintf(fId,Descript);fprintf(fId,'</description>\n');
end;
fprintf(fId,'		<styleUrl>#');fprintf(fId,LineStyleId);fprintf(fId,'</styleUrl>\n');
fprintf(fId,'		<LineString>\n');
fprintf(fId,'			<extrude>0</extrude>\n');
fprintf(fId,'			<tessellate>1</tessellate>\n');
fprintf(fId,'			<altitudeMode>');fprintf(fId,altitudeMode);fprintf(fId,'</altitudeMode>\n');
fprintf(fId,'			<gx:altitudeMode>');fprintf(fId,altitudeModeG);fprintf(fId,'</gx:altitudeMode>\n');
fprintf(fId,'			<coordinates>\n');
fprintf(fId,'				');fprintf(fId,'%0.12f,',tmp(:));fseek(fId,-1,'cof');fprintf(fId, '\n');
fprintf(fId,'			</coordinates>\n');
fprintf(fId,'		</LineString>\n');
fprintf(fId,'	</Placemark>\n');

%mail@ge0mlib.com 21/08/2021