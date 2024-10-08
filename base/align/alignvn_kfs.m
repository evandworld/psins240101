function [att0, attk, xkpk, kfs] = alignvn_kfs(imu, qnb, pos, phi0, imuerr, wvn, ts)
% SINS initial align uses Kalman filter with vn as measurement.
% Kalman filter states: 
%    [phiE,phiN,phiU, dvE,dvN,dvU, ebx,eby,ebz, dbx,dby,dbz]'.
%
% Prototype: [att0, attk, xkpk] = alignvn(imu, qnb, pos, phi0, imuerr, wvn, ts)
% Inputs: imu - IMU data
%         qnb - coarse attitude quaternion
%         pos - position
%         phi0 - initial misalignment angles estimation
%         imuerr - IMU error setting
%         wvn - velocity measurement noise (3x1 vector)
%         ts - IMU sampling interval
% Output: att0 - attitude align result
%         attk, xkpk - for debug
%         kf - kf statistic
%
% See also  alignvn, kfstat.

% Copyright(c) 2009-2018, by Gongmin Yan, All rights reserved.
% Northwestern Polytechnical University, Xi An, P.R.China
% 17/06/2018
global glv
    if nargin<4,  phi0 = [1.5; 1.5; 3]*glv.deg;  end
    if nargin<5,  imuerrset(0.01, 100, 0.001, 1);  end
    if nargin<6,  wvn = [0.01; 0.01; 0.01];  end
    if nargin<7,  ts = imu(2,7)-imu(1,7);  end
    if length(qnb)==3, qnb=a2qua(qnb); end  % if input qnb is Eular angles.
    nn = 2; nts = nn*ts;
    len = fix(length(imu)/nn)*nn;
    eth = earth(pos); vn = zeros(3,1); Cnn = rv2m(-eth.wnie*nts/2);
    kf = avnkfinit(nts, pos, phi0, imuerr, wvn);
    [attk, xkpk] = prealloc(fix(len/nn), 4, 2*kf.n+1);
    ki = timebar(nn, len, 'Initial align using vn as meas.');
    kfs = kfstat([], kf);
    for k=1:nn:len-nn+1
        wvm = imu(k:k+nn-1,1:6); t = imu(k+nn-1,7);
        [phim, dvbm] = cnscl(wvm);
        Cnb = q2mat(qnb);
        dvn = Cnn*Cnb*dvbm;
        vn = vn + dvn + eth.gn*nts;
        %qnb = qupdt(qnb, phim-Cnb'*eth.wnin*nts);
        qnb = qupdt2(qnb, phim, eth.wnin*nts);
        Cnbts = Cnb*nts;
        kf.Phikk_1(4:6,1:3) = askew(dvn);
            kf.Phikk_1(1:3,7:9) = -Cnbts; kf.Phikk_1(4:6,10:12) = Cnbts;
        kf.Gammak = [-Cnb,zeros(3); zeros(3),Cnb; zeros(6)];
        if norm(phim)<100*glv.dps*nts
            kf = kfupdate(kf, vn);
%             kfs = kfstat(kfs, kf, 'B');
            kfs = kfstat(kfs, kf, 'T');   kfs = kfstat(kfs, kf, 'M');
        else
            kf = kfupdate(kf);
            kfs = kfstat(kfs, kf, 'T');
        end
%         kfs = kfstat(kfs, kf, 'B');
        qnb = qdelphi(qnb, 0.1*kf.xk(1:3)); kf.xk(1:3) = 0.9*kf.xk(1:3);
        vn = vn-0.1*kf.xk(4:6);  kf.xk(4:6) = 0.9*kf.xk(4:6);
        attk(ki,:) = [q2att(qnb)', t];
        xkpk(ki,:) = [kf.xk; diag(kf.Pxk); t]';
        ki = timebar;
    end
    attk(ki:end,:) = []; xkpk(ki:end,:) = [];
    att0 = attk(end,1:3)';
    resdisp('Initial align attitudes (arcdeg)', att0/glv.deg);
    avnplot(attk, xkpk);
    kfs = kfstat(kfs);
    kfsplot(kfs, 0);
    
function kf = avnkfinit(nts, pos, phi0, imuerr, wvn)
    eth = earth(pos); wnie = eth.wnie;
    kf = []; kf.s = 1; kf.nts = nts;
% 	kf.Qk = diag([imuerr.web; imuerr.wdb; zeros(6,1)])^2*nts;
	kf.Qk = diag([imuerr.web; imuerr.wdb])^2*nts;  kf.l = 6;
    kf.Gammak = 1;
	kf.Rk = diag(wvn)^2;
	kf.Pxk = diag([phi0; [1;1;1]; imuerr.eb; imuerr.db])^2;
	Ft = zeros(12); Ft(1:3,1:3) = askew(-wnie); kf.Phikk_1 = eye(12)+Ft*nts;
	kf.Hk = [zeros(3),eye(3),zeros(3,6)];
    [kf.m, kf.n] = size(kf.Hk);
    kf.I = eye(kf.n);
    kf.xk = zeros(kf.n, 1);
    kf.adaptive = 0;
    kf.xconstrain = 0; kf.pconstrain = 0;
    kf.fading = 1;

function avnplot(attk, xkpk)
global glv
    t = attk(:,end);
    myfigure;
	subplot(421); plot(t, attk(:,1:2)/glv.deg); xygo('pr')
	subplot(423); plot(t, attk(:,3)/glv.deg); xygo('y');
	subplot(425); plot(t, xkpk(:,7:9)/glv.dph); xygo('eb'); 
	subplot(427); plot(t, xkpk(:,10:12)/glv.ug); xygo('db'); 
	subplot(422); plot(t, sqrt(xkpk(:,13:15))/glv.min); xygo('phi');
	subplot(424); plot(t, sqrt(xkpk(:,16:18))); xygo('dV');
	subplot(426); plot(t, sqrt(xkpk(:,19:21))/glv.dph); xygo('eb');
 	subplot(428); plot(t, sqrt(xkpk(:,22:24))/glv.ug); xygo('db');   
    
function kfsplot(kfs, ispercent)
global glv
    myfigure, % mesh(repmat((1:n)',1,2*n+m),repmat(1:2*n+m,n,1),kfs.pqr);
    if ispercent==1
        pqr = [kfs.p, kfs.q, kfs.r]*100;
        subplot(221), bar(pqr(1:3,:)'); title('( a )'); xygo('j', 'Percentage'); legend('\phi_E', '\phi_N', '\phi_U')
        subplot(222), bar(pqr(4:6,:)'); title('( b )'); xygo('j', 'Percentage'); legend('\deltav^n_E', '\deltav^n_N', '\deltav^n_U')
        subplot(223), bar(pqr(7:9,:)'); title('( c )'); xygo('j', 'Percentage'); legend('\epsilon^b_x', '\epsilon^b_y', '\epsilon^b_z')
        subplot(224), bar(pqr(10:12,:)'); title('( d )'); xygo('j', 'Percentage'); legend('\nabla^b_x', '\nabla^b_y', '\nabla^b_z')
    else  % ?
        pqr = sqrt([kfs.p, kfs.q, kfs.r]); Pii = diag(kfs.Pk);  % 12+6+3
        for k=1:length(pqr), pqr(:,k)=sqrt(pqr(:,k).*Pii); end
        subplot(221), bar(pqr(1:3,:)'/glv.min); xygo('j', 'phi');  legend('\phi_E', '\phi_N', '\phi_U')
        subplot(222), bar(pqr(4:6,:)'); xygo('j', 'dV'); legend('\deltav^n_E', '\deltav^n_N', '\deltav^n_U')
        subplot(223), bar(pqr(7:9,:)'/glv.dph); xygo('j', 'eb'); legend('\epsilon^b_x', '\epsilon^b_y', '\epsilon^b_z')
        subplot(224), bar(pqr(10:12,:)'/glv.ug); xygo('j', 'db'); legend('\nabla^b_x', '\nabla^b_y', '\nabla^b_z')
    end


