T=1;%����ʱ��
outdoor_sensor_data=260;
indoor_sensor_data=101;
sensor_data=outdoor_sensor_data+indoor_sensor_data;
ZALL=zeros(4,sensor_data);
[ground_truthx,ground_truthy,heading,velocity]=Ground_Truth(); 

for n=1:sensor_data
        if n<102
            gx(n)=ground_truthx(n)+ wgn(1, 1,  10*log10(10));%���ڹ۲�ֵ����������Ϊ1
            gy(n)=ground_truthy(n)+ wgn(1, 1,  10*log10(10));%���ڹ۲�ֵ����������Ϊ1
        else
            gx(n)=ground_truthx(n)+ wgn(1, 1,  10*log10(100));%����۲�ֵ����������Ϊ10
            gy(n)=ground_truthy(n)+ wgn(1, 1,  10*log10(100));%����۲�ֵ����������Ϊ10
        end
        phi(n)=(heading(n))*pi/180;%�����
        dd(n)=velocity(n);%�ٶ�
        dx(n)=dd(n)*sin(phi(n));%ĳһ���ڵĶ���λ��
        dy(n)=dd(n)*cos(phi(n));%ĳһ���ڵı���λ��
        Ve(n)=dd(n)*sin(phi(n));%��̼�����Ķ����ٶȣ���ʱ��ĳһ���ڵĶ���λ�ƴ���
        Vn(n)=dd(n)*cos(phi(n));%��̼�����ı����ٶȣ���ʱ��ĳһ���ڵı���λ�ƴ���
        ZM(:,n)=[gx(n),gy(n),dx(n),dy(n)];
end

save model ZM