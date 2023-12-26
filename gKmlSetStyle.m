function gKmlSetStyle(fId,StyleId,varargin)
%Write to kml-file "Style" tags; colorMode='normal', gx:labelVisibility=0.
%function gKmlSetStyle(fId,StyleId,varargin), where
%fId- file identifier;
%StyleId - the linestyle unic identificator (string or number); examples: 'Stl09', 28, 'RedStyle';
%varargin - cells; style parameters for elements 'LineStyle', 'BalloonStyle'; example: {'LineStyle',4,'r','ff'}
%if parameter is empty, than it is not set to kml-file (Color and Alpha must be empty both);
%'LineStyle' >>>> Specifies the drawing style (color, color mode, and line width) for all line geometry. Line geometry includes the outlines of outlined polygons and the extruded "tether" of Placemark icons (if extrusion is enabled).
%--- LWidth - width of the line, in pixels; examples: '05', 4;
%--- LColor - line color; the order of expression is bbggrr, where bb=blue(00toff); gg=green(00toff); rr=red(00toff); examples: '00ffff', 'r', [255 255 0];
%--- LAlpha - line transparent; for alpha, '00' is fully transparent and 'ff' is fully opaque; examples: 'ff', 255.
%'PolyStyle' >>>> Specifies the drawing style for all polygons, including polygon extrusions (which look like the walls of buildings) and line extrusions (which look like solid fences).
%--- PColor - polygon color;
%--- PAlpha - polygon transparent;
%--- PFill - Boolean value. Specifies whether to fill the polygon; example: '1',0;
%--- POutline - Boolean value. Specifies whether to outline the polygon. Polygon outlines use the current LineStyle; example: '1',0;
%'BalloonStyle' >>>> Specifies how the description balloon for placemarks is drawn. The <bgColor>, if specified, is used as the background color of the balloon.
%--- bgColor - background color; the order of expression is bbggrr, where bb=blue (00toff); gg=green (00toff); rr=red (00toff); examples: '00ffff', 'r', [255 255 0];
%--- bgAlpha - background transparent; for alpha, '00' is fully transparent and 'ff' is fully opaque; examples: 'ff', 255;
%--- textColor - text color;
%--- textAlpha - text transparent;
%--- text - Text displayed in the balloon; see https://developers.google.com/kml/documentation/kmlreference#balloonstyle for details.
%--- text example - <![CDATA[<b><font color="#CC0000" size="+3">$[name]</b> <br> $[description]]]>
%'IconStyle' >>>> Specifies how icons for point Placemarks are drawn, both in the Places panel and in the 3D viewer of Google Earth. The <Icon> element specifies the icon image. The <scale> element specifies the x, y scaling of the icon. The color specified in the <color> element of <IconStyle> is blended with the color of the <Icon>.
%--- iColor - icon color;
%--- iAlpha - icon transparent;
%--- iScale - resizes the icon (default=1);
%--- iHeading - compass direction, in degrees; default=0 (North); values range from 0 to +-180 degrees;
%--- iHref - an HTTP address or a local file specification used to load an icon; example: http://maps.google.com/mapfiles/kml/pal3/icon21.png
%--- hS - specifies the position within the Icon that is "anchored" to the <Point> specified in the Placemark
%--- hS={hS_x,hS_y,hS_xunits,hS_yunits}; Specifies the position within the Icon that is "anchored" to the <Point> specified in the Placemark. The x and y values can be specified in three different ways: as pixels ("pixels"), as fractions of the icon ("fraction"), or as inset pixels ("insetPixels"), which is an offset in pixels from the upper right corner of the icon. The x and y positions can be specified in different ways—for example, x can be in pixels and y can be a fraction. The origin of the coordinate system is in the lower left corner of the icon.
%---     x - Either the number of pixels, a fractional component of the icon, or a pixel inset indicating the x component of a point on the icon.
%---     y - Either the number of pixels, a fractional component of the icon, or a pixel inset indicating the y component of a point on the icon.
%---     xunits - Units in which the x value is specified. A value of fraction indicates the x value is a fraction of the icon. A value of pixels indicates the x value in pixels. A value of insetPixels indicates the indent from the right edge of the icon.
%---     yunits - Units in which the y value is specified. A value of fraction indicates the y value is a fraction of the icon. A value of pixels indicates the y value in pixels. A value of insetPixels indicates the indent from the top edge of the icon.
%'LabelStyle' >>>> Specifies how the <name> of a Feature is drawn in the 3D viewer. A custom color, color mode, and scale for the label (name) can be specified.
%--- LbColor - label color;
%--- LbAlpha - label transparent;
%--- LbScale - resizes the label.
%Function Example:
%gKmlSetStyle(fId,'st001',{'LineStyle',4,'r','ff'},{'BalloonStyle','c','0f','b','ff','Area01'});
%gKmlSetStyle(fId,'style02',{'LineStyle',4,'r','ff'},{'PolyStyle','b','5f','1','0'});

if isnumeric(StyleId),StyleId=num2str(StyleId);end;
fprintf(fId,'	<Style id="');fprintf(fId,StyleId);fprintf(fId,'">\n');
for n=1:numel(varargin),
    switch varargin{n}{1},
        case 'LineStyle',
            %{'LineStyle',LWidth,LColor,LAlpha} // {'LineStyle',4,'r','ff'}
            LWidth=varargin{n}{2};LColor=varargin{n}{3};LAlpha=varargin{n}{4};
            if ~(isempty(LColor)&&isempty(LAlpha)),[LColor,LAlpha]=gKmlColor(LColor,LAlpha);end;
            if ~(isempty(LWidth)), if isnumeric(LWidth),LWidth=num2str(LWidth);end;end;
            fprintf(fId,'			<LineStyle>\n');
            fprintf(fId,'				<colorMode>normal</colorMode>\n');
            if ~(isempty(LColor)&&isempty(LAlpha)),fprintf(fId,'				<color>#');fprintf(fId,LAlpha);fprintf(fId,LColor);fprintf(fId, '</color>\n');end;
            if ~(isempty(LWidth)), fprintf(fId,'				<width>');fprintf(fId,LWidth);fprintf(fId, '</width>\n');end;
            %<gx:outerColor>ffffffff</gx:outerColor> <gx:outerWidth>0.0</gx:outerWidth> <gx:physicalWidth>0.0</gx:physicalWidth>
            fprintf(fId,'				<gx:labelVisibility>0</gx:labelVisibility>\n');
            fprintf(fId,'			</LineStyle>\n');
        case 'PolyStyle',
            %{'PolyStyle',PColor,PAlpha,PFill,POutline} // 
            PColor=varargin{n}{2};PAlpha=varargin{n}{3};PFill=varargin{n}{4};POutline=varargin{n}{5};
            if ~(isempty(PColor)&&isempty(PAlpha)),[PColor,PAlpha]=gKmlColor(PColor,PAlpha);end;
            if ~(isempty(PFill)),if isnumeric(PFill),PFill=num2str(PFill);end;end;
            if ~(isempty(POutline)),if isnumeric(POutline),POutline=num2str(POutline);end;end;
            fprintf(fId,'			<PolyStyle>\n');
            fprintf(fId,'				<colorMode>normal</colorMode>\n');
            if ~(isempty(PColor)&&isempty(PAlpha)),fprintf(fId,'				<color>#');fprintf(fId,PAlpha);fprintf(fId,PColor);fprintf(fId, '</color>\n');end;
            if ~(isempty(PFill)),fprintf(fId,'				<fill>');fprintf(fId,PFill);fprintf(fId, '</fill>\n');end;
            if ~(isempty(POutline)),fprintf(fId,'				<outline>');fprintf(fId,POutline);fprintf(fId, '</outline>\n');end;
            fprintf(fId,'			</PolyStyle>\n');
        case 'BalloonStyle',
            %{'BalloonStyle',bgColor,bgAlpha,textColor,textAlpha,text} // {'BalloonStyle','c','0f','b','ff','Area01'}
            bgColor=varargin{n}{2};bgAlpha=varargin{n}{3};textColor=varargin{n}{4};textAlpha=varargin{n}{5};text=varargin{n}{6};
            if ~(isempty(bgColor)&&isempty(bgAlpha)),[bgColor,bgAlpha]=gKmlColor(bgColor,bgAlpha);end;
            if ~(isempty(textColor)&&isempty(textAlpha)),[textColor,textAlpha]=gKmlColor(textColor,textAlpha);end;
            fprintf(fId,'			<BalloonStyle>\n');
            if ~(isempty(bgColor)&&isempty(bgAlpha)),fprintf(fId,'				<bgColor>#');fprintf(fId,bgAlpha);fprintf(fId,bgColor);fprintf(fId, '</bgColor>\n');end;
            if ~(isempty(textColor)&&isempty(textAlpha)),fprintf(fId,'				<textColor>#');fprintf(fId,textAlpha);fprintf(fId,textColor);fprintf(fId, '</textColor>\n');end;
            if ~isempty(text),fprintf(fId,'				<text>');fprintf(fId,text);fprintf(fId,'</text>\n');end;
            fprintf(fId,'				<displayMode>default</displayMode>\n');
            fprintf(fId,'			</BalloonStyle>\n');
        case 'IconStyle',
            %{'IconStyle',iColor,iAlpha,iScale,iHeading,iHref,{hS_x,hS_y,hS_xunits,hS_yunits}} // 
            iColor=varargin{n}{2};iAlpha=varargin{n}{3};iScale=varargin{n}{4};iHeading=varargin{n}{5};iHref=varargin{n}{6};hS=varargin{n}{7};
            if ~(isempty(iColor)&&isempty(iAlpha)),[iColor,iAlpha]=gKmlColor(iColor,iAlpha);end;
            if ~(isempty(iScale)),if isnumeric(iScale),iScale=num2str(iScale);end;end;
            if ~(isempty(iHeading)),if isnumeric(iHeading),iHeading=num2str(iHeading);end;end;
            fprintf(fId,'		<IconStyle>\n');
            if ~(isempty(iColor)&&isempty(iAlpha)),fprintf(fId,'				<color>#');fprintf(fId,iAlpha);fprintf(fId,iColor);fprintf(fId, '</color>\n');end;
            fprintf(fId,'				<colorMode>normal</colorMode>\n');
            if ~(isempty(iScale)),fprintf(fId,'				<scale>');fprintf(fId,iScale);fprintf(fId, '</scale>\n');end;
            if ~(isempty(iHeading)),fprintf(fId,'				<heading>');fprintf(fId,iHeading);fprintf(fId, '</heading>\n');end;
            fprintf(fId,'				<Icon>\n');
            if ~isempty(iHref),fprintf(fId,'					<href>');fprintf(fId,iHref);fprintf(fId, '</href>\n');end;
            fprintf(fId,'				</Icon>\n');
            if ~isempty(hS),fprintf(fId,'				<hotSpot x="');fprintf(fId,hS{1});fprintf(fId,'" y="');fprintf(fId,hS{2});fprintf(fId,'" xunits="');fprintf(fId,hS{3});fprintf(fId,'" yunits="');fprintf(fId,hS{4});fprintf(fId,'"/>');end;
            fprintf(fId,'		</IconStyle>\n');
        case 'LabelStyle',
            %{'LabelStyle',LbColor,LbAlpha,LbScale} // 
            LbColor=varargin{n}{2};LbAlpha=varargin{n}{3};LbScale=varargin{n}{4};
            if ~(isempty(LbColor)&&isempty(LbAlpha)),[LbColor,LbAlpha]=gKmlColor(LbColor,LbAlpha);end;
            if ~(isempty(LbScale)),if isnumeric(LbScale),LbScale=num2str(LbScale);end;end;
            fprintf(fId,'			<LabelStyle>\n');
            fprintf(fId,'				<colorMode>normal</colorMode>\n');
            if ~(isempty(LbColor)&&isempty(LbAlpha)),fprintf(fId,'				<color>#');fprintf(fId,LbAlpha);fprintf(fId,LbColor);fprintf(fId, '</color>\n');end;
            if ~(isempty(LbScale)),fprintf(fId,'				<scale>');fprintf(fId,LbScale);fprintf(fId, '</scale>\n');end;
            fprintf(fId,'			</LabelStyle>\n');
        %case 'ListStyle',
        otherwise, warning(['Incorrect style name: ' varargin{n}{1}]);
    end;
end;
fprintf(fId,'	</Style>\n');

%mail@ge0mlib.com 22/04/2021