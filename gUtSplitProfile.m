function gUtSplitProfile(fname,dst,pt_num,mlt,head_num,delim,digit_num,fl)
%Delete zeros from XYZ-profile and split it to sections by holes; save results to current folder
%gUtSplitProfile(fname,dst,pt_num,mlt,head_num,delim,digit_num,fl), where
%fname - file's name;
%dst - XY-distance for hole detection (if bigger, then hole);
%pt_num - minimum points in section (if smaller, than section will be deleted);
%mult - multiple for Z;
%head_num - number header's rows for input XYZ-file (will be passed)
%delim - delimiter for input XYZ-file;
%digit_num - number of digits for output XYZ-files;
%fl - flag for plotting.
%Example:
%gUtSplitProfile('e:\037\S2_0_80m.xyz',15,10,-1,3,' ',3,1);

A=dlmread(fname,delim,head_num,0);A(A(:,3)==0,:)=[];A(:,3)=A(:,3).*mlt;
%===sort points in one line; first pass from random point; second pass from last point;
tmp=A;B=tmp;tmp(1,:)=[];n=1;
while ~isempty(tmp)
    [~,I]=min(sqrt((tmp(:,1)-B(n,1)).^2+(tmp(:,2)-B(n,2)).^2));B(n+1,:)=tmp(I,:);tmp(I,:)=[];n=n+1;
end
tmp=B;B(1,:)=tmp(end,:);tmp(end,:)=[];n=1;
while ~isempty(tmp)
    [~,I]=min(sqrt((tmp(:,1)-B(n,1)).^2+(tmp(:,2)-B(n,2)).^2));B(n+1,:)=tmp(I,:);tmp(I,:)=[];n=n+1;
end
%===calculate hole position
C=sqrt(diff(B(:,1)).^2+diff(B(:,2)).^2);L=find(C>dst);
%===put each section to own cell
if ~isempty(L)
    c=cell(numel(L)+1,1);
    c{1}=B(1:L(1),:); %put first section data to cell
    for n=1:numel(L)-1,c{n+1}=B(L(n)+1:L(n+1),:);end %put section's data to cells
    c{end}=B(L(end)+1:length(B),:); %put last section data to cell
else,c{1}=B;
end
for n=numel(c):-1:1;if length(c{n})<pt_num, c(n)=[];end;end %delete small sections
%===write cells to file
L=find(fname=='.');if isempty(L),L=numel(fname)+1;end
for n=1:numel(c),dlmwrite([fname(1:L(end)-1) '_' num2str(n,'%02d') '.xyz'],c{n},'precision',['%.' num2str(digit_num) 'f'],'delimiter',delim,'newline','pc');end
%===draw plot
if fl
    plot(A(:,1),A(:,2),'.b');axis equal;hold on;plot(B(:,1),B(:,2),'-b');
    for n=1:numel(c),plot(c{n}(:,1),c{n}(:,2),'o');end;hold off;
end


