initfile = dir('psinsinit.m');
if isempty(initfile) 
    uiwait(warndlg('初始化失败！请将Matlab当前工作目录设置为PSINS。', 'PSINS', 'modal'));
    return;
end

pp = [';', path, ';'];
kpsins = strfind(pp, 'psins');
ksemicolon = strfind(pp, ';');
krm = length(kpsins);
for k = 1:krm
    k1 = find(ksemicolon < kpsins(k), 1, 'last');
    k2 = find(kpsins(k) < ksemicolon, 1, 'first');
    pk = pp(ksemicolon(k1) + 1 : ksemicolon(k2) - 1);
    rmpath(pk);
end

rootpath = pwd;
pp = genpath(rootpath);
mytestflag = 0;
if exist('mytest\mytestinit.m', 'file')
    mytestflag = 1;
end
datapath = [rootpath, '\data\'];
if isempty(find(rootpath == '\', 1))
    rootpath(rootpath == '\') = '/';
    datapath(datapath == '\') = '/';
    pp(pp == '\') = '/';
end
addpath(pp);
res = savepath;

fid = fopen('psinsenvi.m', 'wt');
fprintf(fid, 'function [rpath, dpath, mytestflag] = psinsenvi()\n');
fprintf(fid, '\trpath = ''%s'';\n', rootpath);
fprintf(fid, '\tdpath = ''%s'';\n', datapath);
fprintf(fid, '\tmytestflag = %d;\n', mytestflag);
fclose(fid);
clear pp rootpath datapath res fid mytestflag;
glvs;
uiwait(msgbox('         PSINS工具箱初始化完成！     ', 'PSINS', 'modal'));

glvs;
psinstypedef(193);
% trj = trjfile('trj10ms.mat');
trj = trjfile('trjEV.mat');
[nn, ts, nts] = nnts(2, trj.ts);

imuerr = imuerrset(0.03, 100, 0.001, 10);
imu = imuadderr(trj.imu, imuerr);

davp0 = avperrset([0.5; -0.5; 30], 0.1, [1; 1; 3]);

lever = [1; 2; 3]; dT = 0.1;

gps = gpssimu(trj.avp, davp0(4:6), davp0(7:9), 1, lever, dT);
imugpssyn(imu(:,7), gps(:,end));

ins = insinit(trj.avp0(1:9), ts, davp0);  
ins.nts = nts;

r0 = poserrset([1; 1; 1]);
kf = kfinit(ins, davp0, imuerr, lever, dT, r0);

len = length(imu); 
[avp, xkpk] = prealloc(fix(len/nn), 10, 2*kf.n+1);

timebar(nn, len, '19状态SINS/GPS仿真'); 
ki = 1;

for k = 1:nn:len-nn+1
    k1 = k + nn - 1; 
    wvm = imu(k:k1, 1:6); 
    t = imu(k1, end);
    ins = insupdate(ins, wvm);
    kf.Phikk_1 = kffk(ins);
    kf = kfupdate(kf);
    [kgps, dt] = imugpssyn(k, k1, 'F');
    if kgps > 0
        posGPS = gps(kgps, 4:6)';
        ins = inslever(ins);
        kf.Hk = kfhk(ins);
        kf = kfupdate(kf, ins.posL - ins.Mpvvn * dt - posGPS, 'M');
        [kf, ins] = kffeedback(kf, ins, 1, 'V');
        avp(ki,:) = [ins.avp', t];
        xkpk(ki,:) = [kf.xk; diag(kf.Pxk); t]';  
        ki = ki + 1;
    end
    timebar;
end
avp(ki:end,:) = []; 
xkpk(ki:end,:) = [];

avperr = avpcmpplot(trj.avp, avp);
kfplot(xkpk, avperr, imuerr, lever, dT);

% 初始经度、纬度和高度（自定义）
lon0 = 106.589421;
lat0 = 29.563361;
alt0 = 0;
R_earth = 6378137; % 地球半径

lon0_rad = deg2rad(lon0);
lat0_rad = deg2rad(lat0);

x0 = R_earth * cos(lat0_rad) * cos(lon0_rad);
y0 = R_earth * cos(lat0_rad) * sin(lon0_rad);
z0 = R_earth * sin(lat0_rad);

t = 0:0.1:100; 
sigma_position = 5; % 位置误差为5m
sigma_velocity = 0.2; % 速度误差为0.2m/s

ideal_gps_data = [x0 + cumsum(0.1 * sin(2*pi*0.01*t')), y0 + cumsum(0.1 * sin(2*pi*0.01*t')), z0 + cumsum(0.01 * sin(2*pi*0.01*t'))];

noisy_gps_data = ideal_gps_data + sigma_position * randn(size(ideal_gps_data));

gps_data = [t', noisy_gps_data];

state = zeros(9, 1);
P = eye(9);
Q = eye(9);
R = eye(3);

fused_data = zeros(length(t), 9);

for k = 1:length(t)
    F = eye(9);
    state = F * state; 
    P = F * P * F' + Q; 
    
    H = eye(3, 9);
    z = gps_data(k, 2:4)' - H * state;
    K = P * H' / (H * P * H' + R);
    state = state + K * z;
    P = (eye(9) - K * H) * P;

    fused_data(k, :) = state';
end

% figure;
% subplot(3, 1, 1); plot(t, fused_data(:, 1)); title('位置X'); xlabel('时间 (s)'); ylabel('位置X (m)');
% subplot(3, 1, 2); plot(t, fused_data(:, 2)); title('位置Y'); xlabel('时间 (s)'); ylabel('位置Y (m)');
% subplot(3, 1, 3); plot(t, fused_data(:, 3)); title('位置Z'); xlabel('时间 (s)'); ylabel('位置Z (m)');

XYZ =  pos2dxyz(trj.avp(:,7:9),trj.avp(1,7:9)');
figure;
subplot(3, 1, 1); plot( XYZ(:, 1)); title('位置X'); xlabel('时间 (s)'); ylabel('位置X (m)');
subplot(3, 1, 2); plot(XYZ(:, 2)); title('位置Y'); xlabel('时间 (s)'); ylabel('位置Y (m)');
subplot(3, 1, 3); plot( XYZ(:, 3)); title('位置Z'); xlabel('时间 (s)'); ylabel('位置Z (m)');


% figure;
% h = plot3(fused_data(:, 1), fused_data(:, 2), fused_data(:, 3), 'b'); grid on;
% title('无人船的3D轨迹');
% xlabel('位置X (m)');
% ylabel('位置Y (m)');
% zlabel('位置Z (m)');
% xlim([min(fused_data(:,1)) max(fused_data(:,1))]);
% ylim([min(fused_data(:,2)) max(fused_data(:,2))]);
% zlim([min(fused_data(:,3)) max(fused_data(:,3))]);
% hold on;
% 
% arrow = quiver3(fused_data(1, 1), fused_data(1, 2), fused_data(1, 3), 0, 0, 0, 'r');
% 
% for k = 2:length(t)
%     if isvalid(h) && isvalid(arrow)
%         set(h, 'XData', fused_data(1:k, 1), 'YData', fused_data(1:k, 2), 'ZData', fused_data(1:k, 3));
%         set(arrow, 'XData', fused_data(k, 1), 'YData', fused_data(k, 2), 'ZData', fused_data(k, 3), ...
%             'UData', fused_data(k, 1) - fused_data(k-1, 1), 'VData', fused_data(k, 2) - fused_data(k-1, 2), 'WData', fused_data(k, 3) - fused_data(k-1, 3));
%         drawnow;
% %         pause(0.1);
%     end
% end

fused_data = pos2dxyz(trj.avp(:,7:9),trj.avp(1,7:9)');
figure;
h = plot3(fused_data(:, 1), fused_data(:, 2), fused_data(:, 3), 'b'); grid on;
title('无人船的3D轨迹');
xlabel('位置X (m)');
ylabel('位置Y (m)');
zlabel('位置Z (m)');
% xlim([min(fused_data(:,1)) max(fused_data(:,1))]);
% ylim([min(fused_data(:,2)) max(fused_data(:,2))]);
% zlim([min(fused_data(:,3))-10 max(fused_data(:,3))+10]);