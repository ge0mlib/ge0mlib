function gKmlSetPolygone(fId,B,L,Z,altitudeMode,PlaceName,LineStyleId,Descript,varargin)
%Write to kml-file "Polygone" tags and data; extrude=0, tessellate=1. A Polygon is defined by an outer boundary and 0 or more inner boundaries; the <coordinates> for polygons must be specified in counterclockwise order; the last point must be equal first point
%A Polygon is defined by an outer boundary and 0 or more inner boundaries. The boundaries, in turn, are defined by LinearRings.
%When a Polygon is extruded, its boundaries are connected to the ground to form additional polygons, which gives the appearance of a building or a box. Extruded Polygons use <PolyStyle> for their color, color mode, and fill.
%The <coordinates> for polygons must be specified in counterclockwise order. Polygons follow the "right-hand rule," which states that if you place the fingers of your right hand in the direction in which the coordinates are specified, your thumb points in the general direction of the geometric normal for the polygon. (In 3D graphics, the geometric normal is used for lighting and points away from the front face of the polygon.)
%Since Google Earth fills only the front face of polygons, you will achieve the desired effect only when the coordinates are specified in the proper order. Otherwise, the polygon will be gray.
%function gKmlSetPolygone(fId,B,L,Z,altitudeMode,PlaceName,LineStyleId,Descript,varargin), where
%fId- file identifier;
%B - latilude vector in degree;
%L - longitude vector in degree;
%Z - coordinate vector along Z-axis depend on altitudeMode; if empty, than ignored (clampToGround and clampToSeaFloor mode used);
%altitudeMode - specifies how altitude components in the <coordinates> element are interpreted; there are (1)clampToGround and clampToSeaFloor, (2)relativeToGround and relativeToSeaFloor, (3)absolute
%PlaceName - the name of place (Polygone);  examples: 'Polygone002', 28;
%LineStyleId - the linestyle unic identificator (string or number); examples: 'Stl09', 28, 'RedStyle';
%Descript - description in a separate window; examples: 'seismic survey, area B005', '<![CDATA[Multichannel Seismic data <br> <img src="InfoB005.jpg" width=300> <br>]]>'
%varargin - a number of cells with "innerBoundary"; cells format is {B,L,Z} or {B,L,[]};
%Function Example:
%gKmlSetPolygone(fId,[64 64.5 63.5 64],[143 140 139 143],[],1,'Polygone01','style02','Polygone examle with style02',{[64 64 63.8],[140.8 140.25 140.3],[]},{[63.98 63.62 63.78],[140 139.30 140.19],[]});

if isempty(Z),Z=zeros(size(B));end;
L=L(:)';B=B(:)';Z=Z(:)';if (B(1)~=B(end))||(L(1)~=L(end))||(Z(1)~=Z(end)),warning('B(1)/L(1)/Z(1) must be equal B(end)/L(end)/Z(end); the last point insert.');B(end+1)=B(1);L(end+1)=L(1);Z(end+1)=Z(1);end;
tmp=[L;B;Z];
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
fprintf(fId,'		<Polygon>\n'); %
fprintf(fId,'			<extrude>0</extrude>\n');
fprintf(fId,'			<tessellate>1</tessellate>\n');
fprintf(fId,'			<altitudeMode>');fprintf(fId,altitudeMode);fprintf(fId,'</altitudeMode>\n');
fprintf(fId,'			<gx:altitudeMode>');fprintf(fId,altitudeModeG);fprintf(fId,'</gx:altitudeMode>\n');
fprintf(fId,'			<outerBoundaryIs>\n');
fprintf(fId,'				<LinearRing>\n');
fprintf(fId,'				<altitudeMode>');fprintf(fId,altitudeMode);fprintf(fId,'</altitudeMode>\n');
fprintf(fId,'				<gx:altitudeMode>');fprintf(fId,altitudeModeG);fprintf(fId,'</gx:altitudeMode>\n');
fprintf(fId,'					<coordinates>\n');
fprintf(fId,'							');fprintf(fId,'%0.12f,',tmp(:));fseek(fId,-1,'cof');fprintf(fId, '\n');
fprintf(fId,'					</coordinates>\n');
fprintf(fId,'				</LinearRing>\n');
fprintf(fId,'			</outerBoundaryIs>\n');
if ~isempty(varargin),
    for n=1:numel(varargin),
        L=varargin{n}{2}(:)';B=varargin{n}{1}(:)';if isempty(varargin{n}{3}),tmp=[L;B;zeros(size(B))];else Z=varargin{n}{3}(:)';tmp=[L;B;Z];end;
        fprintf(fId,'			<innerBoundaryIs>\n');
        fprintf(fId,'				<LinearRing>\n');
        fprintf(fId,'				<altitudeMode>');fprintf(fId,altitudeMode);fprintf(fId,'</altitudeMode>\n');
        fprintf(fId,'				<gx:altitudeMode>');fprintf(fId,altitudeModeG);fprintf(fId,'</gx:altitudeMode>\n');
        fprintf(fId,'					<coordinates>\n');
        fprintf(fId,'							');fprintf(fId,'%0.12f,',tmp(:));fseek(fId,-1,'cof');fprintf(fId, '\n');
        fprintf(fId,'					</coordinates>\n');
        fprintf(fId,'				</LinearRing>\n');
        fprintf(fId,'			</innerBoundaryIs>\n');
    end;
end;
fprintf(fId,'		</Polygon>\n');
fprintf(fId,'	</Placemark>\n');

%mail@ge0mlib.com 21/08/2021