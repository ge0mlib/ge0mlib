function THeader=gSgyTextCorrect(THeader,varargin)
%Replace symbols in the Text Header.
%function THeader=gSgyTextCorrect(THeader,varargin), where
%THeader- input textural header contains 3200 symbols (if length~=3200 then try to use THeader as a txt-file name);
%varargin- data for replace,
%1) there can be struct with fields:
%varargin{1}(n).Pos- text position; varargin{1}(n).Rec- text for writing; varargin{1}(n).Num- max number of symbols for text;
%2) there can be vars: text_for_replace1, position_for_replace1,...text_for_replaceN, position_for_replaceN;
%THeader- output textural header.
%Example: SgyHead.TextualFileHeader=gSgyTextCorrect('c:\temp\THead.txt',StHead);SgyHead.TextualFileHeader=gSgyTextCorrect(SgyHead.TextualFileHeader,'NewText1',15,'NewText2',55);

if numel(THeader)~=3200,
    [fId,mes]=fopen(THeader,'r');if ~isempty(mes), error(['Try to read file: ' mes]);end;
    THeader=fread(fId,inf,'*char');fclose(fId);
    if numel(THeader)~=3200, error('TexturalHeader readed from file, but length is NOT 3200 symbols.');end;
end;
if ~isempty(varargin),
    if isstruct(varargin{1})&&(numel(varargin)==1),
        StHead=varargin{1};
        for n=1:numel(StHead),
            if StHead(n).Num<numel(StHead(n).Rec), error(['gSgyTexturalCorrect big length:' StHead(n).Rec]);end;
            if ~isempty(StHead(n).Rec), THeader(StHead(n).Pos:StHead(n).Pos+numel(StHead(n).Rec)-1)=StHead(n).Rec;end;
        end;
    else
        for n=1:2:numel(varargin),THeader(varargin{n+1}:varargin{n+1}+numel(varargin{n})-1)=varargin{n};end;
    end;
end;

%mail@ge0mlib.com 10/11/2020