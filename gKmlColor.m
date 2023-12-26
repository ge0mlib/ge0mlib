function [LColor,LAlpha]=gKmlColor(LColor,LAlpha)
%Create Color&Alpha in kml-format.
%function [LColor,LAlpha]=gKmlColor(LColor,LAlpha), where
%LColor - color; the order of expression is bbggrr, where bb=blue (00toff); gg=green (00toff); rr=red (00toff); examples: '00ffff', 'r', [255 255 0];
%LAlpha - transparent; for alpha, 00 is fully transparent and ff is fully opaque; ; examples: 'ff', 255.
%Function Example:
%[LColor,LAlpha]=gKmlColor('r',255);

if isempty(LAlpha),LAlpha='ff';end; %set default
if isnumeric(LAlpha),LAlpha=dec2hex(LAlpha(1));end;
if isempty(LColor),LColor='ff0000';end; %set default
if all(isnumeric(LColor)),LColor=[dec2hex(LColor(1)) dec2hex(LColor(2)) dec2hex(LColor(3))];end;
if all(ischar(LColor))&&(numel(LColor)==1),
    switch LColor,
        case 'y',LColor='00ffff'; %yellow
        case 'm',LColor='ff00ff'; %magenta
        case 'c',LColor='ffff00'; %cyan
        case 'r',LColor='0000ff'; %red
        case 'g',LColor='00ff00'; %green
        case 'b',LColor='ff0000'; %blue
        case 'w',LColor='ffffff'; %white
        case 'k',LColor='000000'; %black
        otherwise,LColor='ff0000';warning('Incorrect LColor symbol.');
    end;
end;
if ~(all(ischar(LColor))&&(numel(LColor)==6)&&all(ischar(LAlpha))&&(numel(LAlpha)==2)),error('Some error in LColor or LAlpha output');end;

%mail@ge0mlib.com 22/04/2021