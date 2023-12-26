function gMapPLDraw(f,PL)
%Draw poly lines from Track-polyline structure.
%function gMapPLDraw(figN,PL), where
%f- figure number or handle (if empty, then current figure is used);
%PL- track-polyline structure, field used: PL(n).PLName(?); PL(n).KeyLineDraw(?); PL(n).GpsE; PL(n).GpsN;
%Example: 
%PLLine=gMapPLReadTxt('c:\temp\SSS\V3LinePlan.txt',1,'-c');gMapPLDraw(100,PLLine);axis equal;

if ~isempty(f),
    if isnumeric(f), fM=figure(f); elseif isgraphics(f,'figure'), fM=f; else error('Input var "f" must be figure_number or figure_handle.');end;
    figure(fM);
else fM=gcf;
end;
gca;holdState=fM.CurrentAxes.NextPlot;fM.CurrentAxes.NextPlot='add';
 for n=1:length(PL),
     if isfield(PL(n),'KeyLineDraw'),KeyLineDraw=PL(n).KeyLineDraw; else KeyLineDraw='.-b';end;
     plot(PL(n).GpsE,PL(n).GpsN,KeyLineDraw);
     if isfield(PL(n),'PLName'),
         L=find(~isnan(PL(n).GpsE)&~isnan(PL(n).GpsN));
         text(PL(n).GpsE(L(1)),PL(n).GpsN(L(1)),PL(n).PLName,'FontSize',7,'Color',[0 0 0],'Interpreter','none','VerticalAlignment','baseline');
     end;
    %text(PL(n).GpsE(end),PL(n).GpsN(end),PL(n).PLName,'FontSize',7,'Color',[0 0 0],'Interpreter','none','VerticalAlignment','baseline');%name to end_of_line
    %plot(PL(n).GpsE(100:100:end),PL(n).GpsN(100:100:end),'.b');plot(PL(n).GpsE(1000:1000:end),PL(n).GpsN(1000:1000:end),'.c');%100th point is blue, 1000th point is cyan
    %qtxt=num2str((1:fix(length(PL(n).GpsE)./1000))');text(PL(n).GpsE(1000:1000:end),PL(n).GpsN(1000:1000:end),qtxt,'FontSize',6,'Color',[0 0 1],'Interpreter','none','VerticalAlignment','baseline');%draw point number for each 1000th
 end;
 fM.CurrentAxes.NextPlot=holdState;

%mail@ge0mlib.com 25/10/2020