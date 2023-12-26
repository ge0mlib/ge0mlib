%script gNavTiatTest;
%Calculate "error ellipsoid" for USBL misalignment angles, using 2 ship's location with target's coordinates by USBL.

SU=struct('du',[1;0.5;0.8],'dm',[0;0;0],'LeverUSBL',[3;0;0]); %set USBL and MRU misalignment error, set LeverUSBL in VCS [-0.5;0.5;-1] [1;0.5;0.8] [10;5;0]
%sh1m=[-60;-3;-5];sh2m=[60;3;5]; %set [Head Pitch Roll] for sh1 and sh2
sh1m=[0;0;0];sh2m=[0;0;0]; %set [Head Pitch Roll] for sh1 and sh2
sh1=[0;0;0];sh2=[120;200;0];tr=[120;60;-80]; %set ship coords and target coords
LeverUSBL=gNavTiatLever(-SU.dm(1),-SU.dm(2),-SU.dm(3),SU.LeverUSBL,'frw'); %calculate LeverUSBL in ECS_MRU
%calculate 'true' target coords for ship1
tmp3=gNavTiatLever(-sh1m(1),-sh1m(2),-sh1m(3),tr-sh1,'frw');tmp2=tmp3-LeverUSBL;tmp1=gNavTiatLever(SU.dm(1),SU.dm(2),SU.dm(3),tmp2,'rev');
tr1=gNavTiatLever(-SU.du(1),-SU.du(2),-SU.du(3),tmp1,'frw')+sh1;
%calculate 'true' target coords for ship2
tmp3=gNavTiatLever(-sh2m(1),-sh2m(2),-sh2m(3),tr-sh2,'frw');tmp2=tmp3-LeverUSBL;tmp1=gNavTiatLever(SU.dm(1),SU.dm(2),SU.dm(3),tmp2,'rev');
tr2=gNavTiatLever(-SU.du(1),-SU.du(2),-SU.du(3),tmp1,'frw')+sh2;

%calculate 'dst-residual set'
dd=3;ddd=0.02;[dHu,dPu,dRu]=meshgrid(-dd:ddd:dd,-dd:ddd:dd,-dd:ddd:dd);dst=zeros(size(dHu));%set 'USBL angles error corrections' by Pich&Roll&Head grid
dHm=SU.dm(1);dPm=SU.dm(2);dRm=SU.dm(3);%set 'false' MRU's misalignment angles
LeverU=[0;0;0]; %set 'false' LeverUSBL in ECS_MRU // LeverU=LeverUSBL;
tic;
if 0, disp('Using for-sycle');
    for n=1:numel(dHu),
        %target coordinate recalculate with 'angles correction' for ship1
        tmp1=gNavTiatLever(dHu(n),dPu(n),dRu(n),tr1-sh1,'rev');tmp2=gNavTiatLever(-dHm,-dPm,-dRm,tmp1,'frw');tmp3=tmp2+LeverU;
        r1=gNavTiatLever(sh1m(1),sh1m(2),sh1m(3),tmp3,'rev')+sh1;
        %target coordinate recalculate with 'angles correction' for ship2
        tmp1=gNavTiatLever(dHu(n),dPu(n),dRu(n),tr2-sh2,'rev');tmp2=gNavTiatLever(-dHm,-dPm,-dRm,tmp1,'frw');tmp3=tmp2+LeverU;
        r2=gNavTiatLever(sh2m(1),sh2m(2),sh2m(3),tmp3,'rev')+sh2;
        %distance between sh1&sh2 target locations
        dst(n)=sqrt(sum((r1-r2).^2));
    end;
else disp('Not using for-sycle');
    [X1,Y1,Z1,X2,Y2,Z2]=gNavTiatNLever(dHu,dPu,dRu,[tr1-sh1 tr2-sh2],'rev');
    [X1,Y1,Z1]=gNavTiatLeverN([-dHm;-dPm;-dRm],X1,Y1,Z1,'frw');[X1,Y1,Z1]=gNavTiatLeverN(sh1m,X1+LeverU(1),Y1+LeverU(2),Z1+LeverU(3),'rev');
    [X2,Y2,Z2]=gNavTiatLeverN([-dHm;-dPm;-dRm],X2,Y2,Z2,'frw');[X2,Y2,Z2]=gNavTiatLeverN(sh2m,X2+LeverU(1),Y2+LeverU(2),Z2+LeverU(3),'rev');
    dst=sqrt((X1+sh1(1)-X2-sh2(1)).^2+(Y1+sh1(2)-Y2-sh2(2)).^2+(Z1+sh1(3)-Z2-sh2(3)).^2);
end;
toc;
dst(dst>10)=nan;
%draw figures and slices
figure(1);h=slice(dHu,dPu,dRu,dst,1,0.5,0.8);for n=1:numel(h);h(n).EdgeColor='none';end;xlabel('dH');ylabel('dP');zlabel('dR');
figure(2);h=slice(dHu,dPu,dRu,dst,0.5,1.5,1);for n=1:numel(h);h(n).EdgeColor='none';end;xlabel('dH');ylabel('dP');zlabel('dR');
figure(3);h=slice(dHu,dPu,dRu,dst,-1.5,0,-1.8);for n=1:numel(h);h(n).EdgeColor='none';end;xlabel('dH');ylabel('dP');zlabel('dR');
figure(4);h=slice(dHu,dPu,dRu,dst,0,-0.5,-0.2);for n=1:numel(h);h(n).EdgeColor='none';end;xlabel('dH');ylabel('dP');zlabel('dR');
figure(5);h=slice(dHu,dPu,dRu,dst,0.5,-1,-0.1);for n=1:numel(h);h(n).EdgeColor='none';end;xlabel('dH');ylabel('dP');zlabel('dR');

%mail@ge0mlib.com 07/06/2021