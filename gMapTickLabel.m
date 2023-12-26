function gMapTickLabel(fig,skey,fntSize)
%Remove exponent, set format and font for figure's Tick Labels.
%function gMapTickLabel(fig,key,fntSize), where
%fig- figure number or handle;
%skey- format for label: '$%,.2f', '%g\\circ', '%g%%', '%,g', '%,4.4g','%+4.4g','%04.4g','%-4.4g','%#4.4g' (https://www.mathworks.com/help/matlab/ref/matlab.graphics.axis.decorator.numericruler-properties.html)
%skey can be separate for X and Y axis using cells {'%.1f','%.4f'}; if empty, than format is not changed (font size only).
%fntSize- font size.
%Example: gMapTickLabel(7,'%.2f',12);

%if isnumeric(fig), fM=figure(fig); elseif isgraphics(fig,'figure'), fM=fig; else error('input var "fig" must be figure_number or figure_handle.');end;
%a=fM.CurrentAxes;
figure(fig);a=gca;
if iscell(skey),skey1=skey{1};skey2=skey{2};else skey1=skey;skey2=skey;end;
if ~isempty(skey1),a.YAxis.Exponent=0;a.YAxis.TickLabelFormat=skey1;end;
if ~isempty(skey2),a.XAxis.Exponent=0;a.XAxis.TickLabelFormat=skey2;end;
a.FontSize=fntSize;

%mail@ge0mlib.com 19/01/2021