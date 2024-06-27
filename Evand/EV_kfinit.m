function kf = EV_kfinit(kfinit, ins, varargin)
% 自制的KF初始化程序，应对151的情况（GNSS拒止，仅有气压高度这一个观测）
global glv
[Re,deg,dph,ug,mg] = ... % just for short
    setvals(glv.Re,glv.deg,glv.dph,glv.ug,glv.mg); 
o33 = zeros(3); I33 = eye(3); 
kf = [];
if isstruct(ins),    nts = ins.nts;
else                 nts = ins;
end
switch(kfinit)
    case 151
        psinsdef.kffk = 15;  psinsdef.kfhk = 151;  psinsdef.kfplot = 15;
        [davp, imuerr, rk] = setvals(varargin);
        kf.Qt = diag([imuerr.web; imuerr.wdb; zeros(9,1)])^2;
        kf.Rk = diag(rk)^2;
        kf.Pxk = diag([davp; imuerr.eb; imuerr.db]*1.0)^2;
        kf.Hk = [zeros(1,14), 1];
    otherwise
        warning('选择滤波模型出错');
end
kf = kfinit0(kf, nts);
