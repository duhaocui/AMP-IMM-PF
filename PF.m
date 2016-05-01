%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%�����ʼ������%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PCenter=PF(R)
% clc;
% clear;
% close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ȫ�ֱ�������%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load model ZM;
outdoor_sensor_data=260;
indoor_sensor_data=101;
sensor_data=outdoor_sensor_data+indoor_sensor_data;
ZALL=zeros(4,sensor_data);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%��ȡ����������%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for n=1:sensor_data
        gx(n)=ZM(1,n);
        gy(n)=ZM(2,n);
        dx(n)=ZM(3,n);
        dy(n)=ZM(4,n);
        ZALL(:,n)=[gx(n),gy(n),dx(n),dy(n)];
end

% fgps=fopen('sensor_data_041518.txt','r');%%%���ı�
% for n=1:sensor_data
%     gpsline=fgetl(fgps);%%%��ȡ�ı�ָ���Ӧ����
%     if ~ischar(gpsline) break;%%%�ж��Ƿ����
%     end;
%     %%%%��ȡ��������
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
%         Phi(n)=(data(3,1)+90)*pi/180;%�����>>>>>>> origin/master
%         dd(n)=data(4,1);%ĳһ���ڵ�λ��
%         ZALL(:,n)=[gx(n),gy(n),Phi(n),dd(n)];
% end
% fclose(fgps);%%%%%�ر��ļ�ָ��

% ��������
N = 100;   %��������
Q = 10;      %��������
% R = 10;      %��������
X = zeros(2, sensor_data);    %�洢ϵͳ״̬
Z = zeros(2, sensor_data);    %�洢ϵͳ�Ĺ۲�״̬
P = zeros(2, N);    %��������Ⱥ
PCenter = zeros(2, sensor_data);  %�������ӵ�����λ��
w = zeros(N, 1);         %ÿ�����ӵ�Ȩ��
err = zeros(1,sensor_data);     %���
X(:, 1) = [ZALL(1,1); ZALL(2,1)];     %��ʼϵͳ״̬
Z(:, 1) = [ZALL(1,1); ZALL(2,1)] ;    %��ʼϵͳ�Ĺ۲�״̬
cordinatex=round(ZALL(1,1));
cordinatey=round(ZALL(2,1));
%��ʼ������Ⱥ
for i = 1 : N
    P(:, i) = [randi([cordinatex,cordinatex],1);randi([cordinatey,cordinatey],1)];
    dist = norm(P(:, i)-Z(:, 1));     %�����λ�����ľ���
    w(i) = (1 / sqrt(R) / sqrt(2 * pi)) * exp(-(dist)^2 / 2 / R);   %��Ȩ��
end
PCenter(:, 1) = sum(P, 2) / N;      %�������ӵļ�������λ��
err(1) = norm(X(:, 1) - PCenter(:, 1));     %���Ӽ���������ϵͳ��ʵ״̬�����

%��ʼ�˶�
for k = 2 : sensor_data
       
    %ģ��һ�������˶���״̬
    X(:, k) = X(:, k-1) + [ZALL(3,k); ZALL(4,k)];     %״̬����
    Z(:, k) = ZALL(1:2, k) ;     %�۲ⷽ�� 
   
    %�����˲�
    %Ԥ��
    for i = 1 : N
        P(:, i) = P(:, i) +  [ZALL(3,k); ZALL(4,k)]+ wgn(2, 1, 10*log10(Q));
        dist = norm(P(:, i)-Z(:, k));     %�����λ�����ľ���
        w(i) = (1 / sqrt(R) / sqrt(2 * pi)) * exp(-(dist)^2 / 2 / R);   %��Ȩ��
    end
%��һ��Ȩ��
    wsum = sum(w);
    for i = 1 : N
        w(i) = w(i) / wsum;
    end
   
    %�ز��������£�
    for i = 1 : N
        wmax = 2 * max(w) * rand;  %��һ���ز�������
        index = randi(N, 1);
        while(wmax > w(index))
            wmax = wmax - w(index);
            index = index + 1;
            if index > N
                index = 1;
            end          
        end
        P(:, i) = P(:, index);     %�õ�������
    end
   
    PCenter(:, k) = sum(P, 2) / N;      %�������ӵ�����λ��
   
    %�������
    err(k) = norm(X(:, k) - PCenter(:, k));     %���Ӽ���������ϵͳ��ʵ״̬�����
end

figure;
set(gca,'FontSize',12);
[groundtruthx,groundtruthy]=Ground_Truth();
plot(groundtruthx,groundtruthy,'r');hold on;
plot(PCenter(1,:), PCenter(2,:), 'g');hold off;
axis([cordinatex-100 cordinatex+200 cordinatey-200 cordinatey+100]),grid on;
legend('��ʵ�켣', 'Ŀ���˲�����');
title('PF');
xlabel('x', 'FontSize', 20); ylabel('y', 'FontSize', 20);
axis equal;
