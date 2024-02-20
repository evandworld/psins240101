function [err] = EV_error_draw(draw_flag,avp,avp_,avp_flag)
% avp：基准
% avp_：用于对比的加速度、速度、位置
% avp_flag：选择输出的是a、v、p中的哪一个
%% 绘图
if nargin == 3
    avp_flag = 'p'; % p=位置
end
switch avp_flag
    case 'a'
        avp_flag_bit = 1;
        title_flag = '加速度';
    case 'v'
        avp_flag_bit = 2;
        title_flag = '速度';
    case 'p'
        avp_flag_bit = 3;
        title_flag = '位置';
    otherwise
        warning('绘图时选择avp错误');
end
len = length(avp(:,7));
cir = length(draw_flag(:,1));
figure;
subplot(3,2,1);
for i1 = 1:cir
    hold on
    plot(1:10:len,avp_{i1}(:,3*avp_flag_bit-2)-avp(1:10:len,3*avp_flag_bit-2));
end
title('X轴误差对比-',title_flag);legend(draw_flag);
subplot(3,2,3);
for i1 = 1:cir
    hold on
    plot(1:10:len,avp_{i1}(:,3*avp_flag_bit-1)-avp(1:10:len,3*avp_flag_bit-1));
end
title('Y轴误差对比-',title_flag);
subplot(3,2,5);
for i1 = 1:cir
    hold on
    plot(1:10:len,avp_{i1}(:,3*avp_flag_bit)-avp(1:10:len,3*avp_flag_bit));
end
title('Z轴误差对比-',title_flag);
subplot(3,2,2);
for i1 = 1:cir
    hold on
    cdfplot(abs(avp_{i1}(:,3*avp_flag_bit-2)-avp(1:10:len,3*avp_flag_bit-2)));
end
title('X轴累积概率密度-',title_flag);
subplot(3,2,4);
for i1 = 1:cir
    hold on
    cdfplot(abs(avp_{i1}(:,3*avp_flag_bit-1)-avp(1:10:len,3*avp_flag_bit-1)));
end
title('Y轴累积概率密度-',title_flag);
subplot(3,2,6);
for i1 = 1:cir
    hold on
    cdfplot(abs(avp_{i1}(:,3*avp_flag_bit)-avp(1:10:len,3*avp_flag_bit)));
end
title('Z轴累积概率密度-',title_flag);
%% 误差输出
err = 0; %测试



end


