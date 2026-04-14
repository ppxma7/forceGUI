% close all
% clear all
% clc

thisfile = 'C:\Users\masgh\data\PM\SU06_MCON_25.mat';
load(thisfile)

thisData = Data{1};
Time = Time{1};

Force = (thisData(:,1));
Acq = (thisData(:,2));
Perf = (thisData(:,3));
Target = (thisData(:,4));

fs = 2000; %Set this
num_samples = length(Time); % Number of data points
time = (0:num_samples-1) / fs; % Time vector in seconds

figure
tiledlayout(2,2)
nexttile
plot(Force)
legend(Description(1),'Location','best')

nexttile
plot(Acq)
legend(Description(2),'Location','best')

nexttile
plot(Perf)
hold on
plot(Target)
legend(Description(3:4),'Location','best')

%%

test = S.Data{1};

figure
tiledlayout(4,3)
for ii = 1:size(test,2)
    nexttile
    plot(test(:,ii))
end
%%
figure
tiledlayout(1,3)
nexttile
plot(test(:,5))
hold on
plot(test(:,12))
nexttile
plot(test(:,8))
hold on
plot(test(:,12))
nexttile
plot(test(:,11))
hold on
plot(test(:,12))


    