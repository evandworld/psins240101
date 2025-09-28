function EV_multi3Ddraw(legend_in,varargin)
tag = {'*','^','v','ko'};

figure;
subplot(221);
hold on
for i1 = 1:size(varargin,2)
    plot(varargin{i1}(:,1),varargin{i1}(:,2),tag{i1});
end
grid on;
xlabel('东向(m)');ylabel('北向(m)');

subplot(222);
hold on
for i1 = 1:size(varargin,2)
    plot(varargin{i1}(:,1),varargin{i1}(:,3),tag{i1});
end
grid on;
xlabel('东向(m)');ylabel('天向(m)');

subplot(223);
hold on
for i1 = 1:size(varargin,2)
    plot(varargin{i1}(:,2),varargin{i1}(:,3),tag{i1});
end
grid on;
xlabel('北向(m)');ylabel('天向(m)');


subplot(224);
hold on
for i1 = 1:size(varargin,2)
    plot3(varargin{i1}(:,1),varargin{i1}(:,2),varargin{i1}(:,3),tag{i1});
end
grid on;
xlabel('东向(m)');ylabel('北向(m)');zlabel('天向(m)');
legend(legend_in);
end