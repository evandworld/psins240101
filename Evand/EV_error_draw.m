function [err] = EV_error_draw(draw_flag,avp_flag,avp,varargin)
% draw_flag：以字符串的形式输入绘图的数据，eg：["EKF"，"UKF"]
% avp：基准
% avp_：用于对比的加速度、速度、位置
% avp_flag：选择输出的是a、v、p中的哪一个,eg：'p'
%% 维度归一化
len_min = length(avp(:,7));
for i1 = 1:size(varargin,2)
    if len_min>size(varargin{i1},1)
        len_min  = size(varargin{i1},1);
    end
end
linetype = ["--",":","-."];


%% 绘图
switch avp_flag
    case 'a'
        avp_flag_bit = 1;
        title_flag = '姿态';
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
cir = length(draw_flag);
figure;
subplot(3,2,1);
for i1 = 1:cir
    hold on
    plot(len/length(varargin{i1}):len/length(varargin{i1}):len,varargin{i1}(:,3*avp_flag_bit-2) ...
        -avp(len/length(varargin{i1}):len/length(varargin{i1}):len,3*avp_flag_bit-2),linetype(mod(i1,length(linetype))+1));
end
title('X轴/维度误差对比-',title_flag);legend(draw_flag);
subplot(3,2,3);
for i1 = 1:cir
    hold on
    plot(len/length(varargin{i1}):len/length(varargin{i1}):len,varargin{i1}(:,3*avp_flag_bit-1)- ...
        avp(len/length(varargin{i1}):len/length(varargin{i1}):len,3*avp_flag_bit-1),linetype(mod(i1,length(linetype))+1));
end
title('Y轴/经度误差对比-',title_flag);
subplot(3,2,5);
for i1 = 1:cir
    hold on
    plot(len/length(varargin{i1}):len/length(varargin{i1}):len,varargin{i1}(:,3*avp_flag_bit)- ...
        avp(len/length(varargin{i1}):len/length(varargin{i1}):len,3*avp_flag_bit),linetype(mod(i1,length(linetype))+1));
end
title('Z轴/高度误差对比-',title_flag);
subplot(3,2,2);
for i1 = 1:cir
    hold on
    h = cdfplot(abs(varargin{i1}(:,3*avp_flag_bit-2)- ...
        avp(len/length(varargin{i1}):len/length(varargin{i1}):len,3*avp_flag_bit-2)));
    set(h,'LineStyle',linetype(mod(i1,length(linetype))+1))
end
title('X-误差abs累积概率密度-',title_flag);
subplot(3,2,4);
for i1 = 1:cir
    hold on
    h = cdfplot(abs(varargin{i1}(:,3*avp_flag_bit-1)- ...
        avp(len/length(varargin{i1}):len/length(varargin{i1}):len,3*avp_flag_bit-1)));
    set(h,'LineStyle',linetype(mod(i1,length(linetype))+1))
end
title('Y-误差abs累积概率密度-',title_flag);
subplot(3,2,6);
for i1 = 1:cir
    hold on
    h = cdfplot(abs(varargin{i1}(:,3*avp_flag_bit)- ...
        avp(len/length(varargin{i1}):len/length(varargin{i1}):len,3*avp_flag_bit)));
    set(h,'LineStyle',linetype(mod(i1,length(linetype))+1))
end
title('Z轴-误差abs累积概率密度-',title_flag);


end


