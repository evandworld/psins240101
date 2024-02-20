function [err] = EV_error_draw(draw_flag,avp,avp_,avp_flag)
% avp����׼
% avp_�����ڶԱȵļ��ٶȡ��ٶȡ�λ��
% avp_flag��ѡ���������a��v��p�е���һ��
%% ��ͼ
if nargin == 3
    avp_flag = 'p'; % p=λ��
end
switch avp_flag
    case 'a'
        avp_flag_bit = 1;
        title_flag = '���ٶ�';
    case 'v'
        avp_flag_bit = 2;
        title_flag = '�ٶ�';
    case 'p'
        avp_flag_bit = 3;
        title_flag = 'λ��';
    otherwise
        warning('��ͼʱѡ��avp����');
end
len = length(avp(:,7));
cir = length(draw_flag(:,1));
figure;
subplot(3,2,1);
for i1 = 1:cir
    hold on
    plot(1:10:len,avp_{i1}(:,3*avp_flag_bit-2)-avp(1:10:len,3*avp_flag_bit-2));
end
title('X�����Ա�-',title_flag);legend(draw_flag);
subplot(3,2,3);
for i1 = 1:cir
    hold on
    plot(1:10:len,avp_{i1}(:,3*avp_flag_bit-1)-avp(1:10:len,3*avp_flag_bit-1));
end
title('Y�����Ա�-',title_flag);
subplot(3,2,5);
for i1 = 1:cir
    hold on
    plot(1:10:len,avp_{i1}(:,3*avp_flag_bit)-avp(1:10:len,3*avp_flag_bit));
end
title('Z�����Ա�-',title_flag);
subplot(3,2,2);
for i1 = 1:cir
    hold on
    cdfplot(abs(avp_{i1}(:,3*avp_flag_bit-2)-avp(1:10:len,3*avp_flag_bit-2)));
end
title('X���ۻ������ܶ�-',title_flag);
subplot(3,2,4);
for i1 = 1:cir
    hold on
    cdfplot(abs(avp_{i1}(:,3*avp_flag_bit-1)-avp(1:10:len,3*avp_flag_bit-1)));
end
title('Y���ۻ������ܶ�-',title_flag);
subplot(3,2,6);
for i1 = 1:cir
    hold on
    cdfplot(abs(avp_{i1}(:,3*avp_flag_bit)-avp(1:10:len,3*avp_flag_bit)));
end
title('Z���ۻ������ܶ�-',title_flag);
%% ������
err = 0; %����



end


