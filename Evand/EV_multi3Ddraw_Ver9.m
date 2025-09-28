function EV_multi3Ddraw_Ver9(legend_in,varargin)
tag = {'*','^','v'};

figure;
subplot(221);
hold on
for i1 = 1:size(varargin,2)
    if i1 <= 3
        plot(varargin{i1}(:,1),varargin{i1}(:,2),tag{i1});
    else
        plot(varargin{i1}(:,1),varargin{i1}(:,2),'ko', 'MarkerFaceColor', 'k');
    end
end
grid on;
xlabel('东向(m)');ylabel('北向(m)');

subplot(222);
hold on
for i1 = 1:size(varargin,2)
    if i1 <= 3
        plot(varargin{i1}(:,1),varargin{i1}(:,3),tag{i1});
    else
        plot(varargin{i1}(:,1),varargin{i1}(:,3),'ko', 'MarkerFaceColor', 'k');
    end
end
grid on;
xlabel('东向(m)');ylabel('天向(m)');

subplot(223);
hold on
for i1 = 1:size(varargin,2)
    if i1 <= 3
        plot(varargin{i1}(:,2),varargin{i1}(:,3),tag{i1});
    else
        plot(varargin{i1}(:,2),varargin{i1}(:,3),'ko', 'MarkerFaceColor', 'k');
    end
end
grid on;
xlabel('北向(m)');ylabel('天向(m)');


subplot(224);
hold on
for i1 = 1:size(varargin,2)
    if i1 <= 3
        plot3(varargin{i1}(:,1),varargin{i1}(:,2),varargin{i1}(:,3),tag{i1});
    else
        plot3(varargin{i1}(:,1),varargin{i1}(:,2),varargin{i1}(:,3),'ko', 'MarkerFaceColor', 'k');
    end
end
grid on;
view(3);
xlabel('东向(m)');ylabel('北向(m)');zlabel('天向(m)');
legend(legend_in);
% 总标题
sgtitle('误差分布图像');
