function [err3axis] = EV_error_output(out_flag,avp_flag,avp,varargin)
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


%% 绘图
switch avp_flag %2024-3-14，目前只能比较位置，速度和加速度的坐标系转换还没有弄
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
out_cir = length(out_flag);

% 计算误差
for i1 = 1:out_cir
    err{i1} = pos2dxyz(varargin{i1}(:,7:9))-pos2dxyz(avp(len/length(varargin{i1}):len/length(varargin{i1}):len,7:9));
    err3axis{i1} = sqrt(diag(err{i1}*err{i1}')); %三轴误差
    fprintf('%s误差绝对值的max如下：\n',title_flag);
    fprintf('%s：X轴%d,Y轴%d,Z轴%d,三轴%d\n',out_flag(i1),max(abs(err{i1}(:,avp_flag_bit-2))),max(abs(err{i1}(:,avp_flag_bit-1))),max(abs(err{i1}(:,avp_flag_bit))),max(err3axis{i1}));

    fprintf('%s误差绝对值的mean如下：\n',title_flag);
    fprintf('%s：X轴%d,Y轴%d,Z轴%d,三轴%d\n',out_flag(i1),mean(abs(err{i1}(:,avp_flag_bit-2))),mean(abs(err{i1}(:,avp_flag_bit-1))),mean(abs(err{i1}(:,avp_flag_bit))),mean(err3axis{i1}));

    fprintf('%s误差的标准差如下：\n',title_flag);
    fprintf('%s：X轴%d,Y轴%d,Z轴%d,三轴%d\n',out_flag(i1),std(err{i1}(:,avp_flag_bit-2)),std(err{i1}(:,avp_flag_bit-1)),std(err{i1}(:,avp_flag_bit)),std(err3axis{i1}));

end
err3axis = cell2mat(err3axis);

end


