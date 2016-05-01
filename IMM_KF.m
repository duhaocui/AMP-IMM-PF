% ����ʽ��ģ��
function PCenter=IMM_KF()
% clc;
% clear;
% close all;
load model ZM
ww=100;%������������
% R=10;
vv1=10*log10(10);%�۲���������
vv2=10*log10(100);%�۲���������

T=1;%����ʱ��
outdoor_sensor_data=260;
indoor_sensor_data=101;
sensor_data=outdoor_sensor_data+indoor_sensor_data;
ZALL=zeros(4,sensor_data);

for n=1:sensor_data
        gx(n)=ZM(1,n);
        gy(n)=ZM(2,n);
        dx(n)=ZM(3,n);
        dy(n)=ZM(4,n);
        Ve(n)=ZM(3,n);%��̼�����Ķ����ٶȣ���ʱ��ĳһ���ڵĶ���λ�ƴ���
        Vn(n)=ZM(4,n);%��̼�����ı����ٶȣ���ʱ��ĳһ���ڵı���λ�ƴ���
        ZALL(:,n)=[gx(n),gy(n),dx(n),dy(n)];
end

% fgps=fopen('sensor_data_041518.txt','r');%%%���ı�
% for n=1:sensor_data
%     gpsline=fgetl(fgps);%%%��ȡ�ı�ָ���Ӧ����
%     if ~ischar(gpsline) break;%%%�ж��Ƿ����
%     end;
%    %%%%��ȡ��������
%    time=sscanf(gpsline,'[Info] 2016-04-15%s(ViewController.m:%d)-[ViewController outputAccelertion:]:lat:%f;lon:%f;heading:%f;distance:%f;beacon_lat:%f;beacon_lon:%f');
%    data=sscanf(gpsline,'[Info] 2016-04-15 %*s (ViewController.m:%*d)-[ViewController outputAccelertion:]:lat:%f;lon:%f;heading:%f;distance:%f;beacon_lat:%f;beacon_lon:%f');
%    if(isempty(data))
%        break;
%    end
%     if n>127 && n<355
%        result=lonLat2Mercator(data(6,1),data(5,1));
%     else
%        result=lonLat2Mercator(data(2,1),data(1,1));
%     end
%         gx(n)=result.X;%GPS��������任��Ķ������꣬���������
%         gy(n)=result.Y;%GPS��������任��ı������꣬���������
%         Phi(n)=(data(3,1)+90)*pi/180;%�����
%         dd(n)=data(4,1);%ĳһ���ڵ�λ��
%         dx(n)=dd(n)*sin(Phi(n))*4;%ĳһ���ڵĶ���λ��
%         dy(n)=dd(n)*cos(Phi(n))*4;%ĳһ���ڵı���λ��
%         Ve(n)=dd(n)*sin(Phi(n));%��̼�����Ķ����ٶȣ���ʱ��ĳһ���ڵĶ���λ�ƴ���
%         Vn(n)=dd(n)*cos(Phi(n));%��̼�����ı����ٶȣ���ʱ��ĳһ���ڵı���λ�ƴ���
%         ZALL(:,n)=[gx(n),gy(n),dx(n),dy(n)];
% end
% fclose(fgps);%%%%%�ر��ļ�ָ��

r=2;%ģ�͵ĸ���   
%ģ��1 
F1=[
    1,0,T,0,0;
    0,1,0,T,0;
    0,0,1,0,0,;
    0,0,0,1,0;
    0,0,0,0,1;
   ];
Q1=diag([0,0,ww,ww,ww]);
R1=diag([vv1,vv1,vv1,vv1]);
P1=diag([0,0,ww,ww,ww]); % �˲���������������
x1=[ZALL(1,1),ZALL(2,1),0,0,0]'; %��ʼ�������й���
%ģ��2
F2=[
    1,0,T,0,0;
    0,1,0,T,0;
    0,0,1,0,0,;
    0,0,0,1,0;
    0,0,0,0,1;
   ];
Q2=diag([0,0,ww,ww,ww]);
R2=diag([vv2,vv2,vv2,vv2]);
P2=diag([0,0,ww,ww,ww]); % �˲���������������
x2=[ZALL(1,1),ZALL(2,1),0,0,0]'; %��ʼ�������й���

F=[F1 F2];
Q=[Q1 Q2];
R=[R1 R2];
P=[P1 P2];
x=[x1 x2];
xx1=zeros(5,1);%ģ��1���Ƶ��м�ֵ
xx2=zeros(5,1);%ģ��2���Ƶ��м�ֵ
xx=[xx1 xx2];
xf=zeros(5,361);

pm=[0.9 0.1
    0.1 0.9];%����Ʒ�ת�ƾ���
u1=0.5;
u2=0.5;
u=[u1 u2];%��ϸ���
um=[0 0
    0 0];%��ϸ��ʾ���
zz=zeros(4,2);%��ģ�͵Ĳ���ֵ�ֲ����Ӧ���˲�ֵ�ľ���
%����ʽ��ģ���㷨
for k=1:361
    %ÿ�μ���֮ǰ��Щ��������
    H=[1,0,0,0,0;
        0,1,0,0,0;
        0,0,1,0,-Vn(k);
        0,0,0,1,Ve(k);
        ];
    c=[0 0];%��ϸ����е�ϵ��
    xx=[xx1 xx2];
    pp=zeros(5,10);
    cc=0;%ģ�͸��ʸ����е�c
    %��ϸ���
    for j=1:r
        for i=1:r
            c(j)=c(j)+pm(i,j)*u(i);
        end
        for i=1:r
            um(i,j)=1/c(j)*pm(i,j)*u(i);
        end
    end
    %��Ϲ���
    for j=1:r
        for i=1:r
            xx(:,j)=xx(:,j)+x(:,i)*um(i,j);
        end
    end
    for j=1:r
        for i=1:r
            pp(:,(j-1)*5+1:(j-1)*5+5)=pp(:,(j-1)*5+1:(j-1)*5+5)+(P(:,(i-1)*5+1:(i-1)*5+5)+(x(:,i)-xx(:,j))*(x(:,i)-xx(:,j))')*um(i,j);
        end
    end
    %ģ�������˲�
    %״̬Ԥ��
    for i=1:r
        x(:,i)=F(:,(i-1)*5+1:(i-1)*5+5)*xx(:,i);
        P(:,(i-1)*5+1:(i-1)*5+5)=F(:,(i-1)*5+1:(i-1)*5+5)*pp(:,(i-1)*5+1:(i-1)*5+5)*F(:,(i-1)*5+1:(i-1)*5+5)'+Q(:,(i-1)*5+1:(i-1)*5+5);
    end
    %����Ԥ��в��Э���������
    for i=1:r
        zz(:,i)=ZALL(:,k)-H*x(:,i);
        S(:,(i-1)*4+1:(i-1)*4+4)=H*P(:,(i-1)*5+1:(i-1)*5+5)*H'+R(:,(i-1)*4+1:(i-1)*4+4);
        L(i)=abs(2*3.1415926*det(S(:,(i-1)*4+1:(i-1)*4+4)))^(-0.5)*exp(-0.5*zz(:,i)'/S(:,(i-1)*4+1:(i-1)*4+4)*zz(:,i));%��Ȼ����
    end
    %�˲�����
    for i=1:r
        K(:,(i-1)*4+1:(i-1)*4+4)=P(:,(i-1)*5+1:(i-1)*5+5)*H'/S(:,(i-1)*4+1:(i-1)*4+4);
        x(:,i)=x(:,i)+K(:,(i-1)*4+1:(i-1)*4+4)*zz(:,i);
        P(:,(i-1)*5+1:(i-1)*5+5)=P(:,(i-1)*5+1:(i-1)*5+5)-K(:,(i-1)*4+1:(i-1)*4+4)*S(:,(i-1)*4+1:(i-1)*4+4)*K(:,(i-1)*4+1:(i-1)*4+4)';
    end
    %ģ�͸��ʸ���
    for j=1:r
        cc=cc+L(j)*c(j);
    end
    for i=1:r
        u(i)=1/cc*L(i)*c(i);
    end
    %�����ں�
    for i=1:r
        xf(:,k)=xf(:,k)+x(:,i)*u(:,i);
        p_model(i,k)=u(i);
    end
end    

PCenter=xf(1:2,:);
cordinatex=ZALL(1,5);
cordinatey=ZALL(2,5);
%��ʾ�˲��켣
figure
set(gca,'FontSize',12);
[groundtruthx,groundtruthy]=Ground_Truth();
plot(groundtruthx,groundtruthy,'r');hold on;
% plot(ZALL(1,:),ZALL(2,:),'o');hold on;
plot(PCenter(1,:),PCenter(2,:),'g');hold off;
axis([cordinatex-100 cordinatex+200 cordinatey-200 cordinatey+100]),grid on;
xlabel('x', 'FontSize', 20); ylabel('y', 'FontSize', 20);
title('IMM-KF');
legend('��ʵ�켣','Ŀ���˲�����');
axis equal;

figure
set(gca,'FontSize',12);
plot(p_model(1,:),'g');hold on;
plot(p_model(2,:),'r');hold on;
xlabel('time/s', 'FontSize', 20); ylabel('model probability', 'FontSize', 20);
title('IMM-KF ģ�͸���');
legend('PF1','PF10');

