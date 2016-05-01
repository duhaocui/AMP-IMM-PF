%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%�����ʼ������%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PCenter=KF(R)

% clc;
% clear;
% close all;
load model ZM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ȫ�ֱ�������%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
d=100;%������������
% R=10;
r=10*log10(R);%�۲���������
T=1;%����ʱ��
outdoor_sensor_data=260;
indoor_sensor_data=101;
sensor_data=outdoor_sensor_data+indoor_sensor_data;
ZALL=zeros(4,sensor_data);
PCenter = zeros(2, sensor_data);  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%��ȡ����������%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

%��������A
A=[
    1,0,T,0,0;
    0,1,0,T,0;
    0,0,1,0,0,;
    0,0,0,1,0;
    0,0,0,0,1;
   ];
%��������Э�������
Q=diag([0,0,d,d,d]);
%�۲�����Э�������
R=diag([r,r,r,r]);
P=diag([0,0,d,d,d]); % �˲���������������
Xfli=[ZALL(1,1),ZALL(2,1),0,0,0]'; %��ʼ�������й���
for k=1:sensor_data
    C=[1,0,0,0,0;
        0,1,0,0,0;
        0,0,1,0,-Vn(k);
        0,0,0,1,Ve(k);
        ];
     K_location(:,k)=Xfli;
     Xest=A*Xfli; % ���¸�ʱ�̵�Ԥ��ֵ ---kalman equation1
     %Xes=A*Xef+Gamma*W(k-1); % Ԥ�������� 
     Pxe=A*P*A'+Q; % Ԥ������Э������ ---kalman equation
     K=Pxe*C'/(C*Pxe*C'+R); % Kalman�˲����� ---kalman equation3
     Xfli=Xest+K*(ZALL(:,k)-C*Xest);% kʱ��Kalman�˲��������ֵ ---kalman equation4
     Px=(eye(5)-K*C)*Pxe;%�˲��������������� ---kalman equation5
end

PCenter=K_location(1:2,:);
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
legend('��ʵ�켣','Ŀ���˲�����');
title('KF');
axis equal;

    

