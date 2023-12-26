function gWfrWrite(fname,Head,Data)
%Write raster-image file with world-file.
%function gWfrWrite(fname,Head,Data), where
%fname - image’s file name with extension (the world-file extension created as first and last letters of the image's extension and ending with a 'w');
%Head - header that includes:
%Head.Color - colormap for palette image;
%Head.Wf - world-file values -- [scaleX skewY skewX scaleY left_up_angle_X left_up_angle_Y];
%Head.K=[a b] - multiple (a) and shift (b) for "Data Original Value" calculation from Color; DataOriginalValue=a*Color+b;
%Head.BgVal - the code of “absent” color (it is means – no data for raster’s pixel with BgVal code);
%Data - raster-image data matrix.
%Example: gWfrWrite('d:\03_Block-3_SSS_Mosaic\Block-3_2.tif',Head,Data);

if ~isempty(Head.Color), imwrite(Data,Head.Color,fname);else imwrite(Data,fname);end;
if ~isempty(Head.K)&&~isempty(Head.BgVal),
    wt=[Head.Wf 9999999999 Head.K Head.BgVal];
    disp('gWfrImWrite --> Head.K=[a b] and Head.BgVal were write to world-file');
else
    wt=Head.Wf;
end;
L=find(fname=='.');dlmwrite([fname(1:L(end)) fname(L(end)+1) fname(end) 'w'],wt','precision','%0.10f','newline','unix');

%mail@ge0mlib.com 19/06/2018