% This Matlab script generates Figure 5 in the paper:
%
% Emil Bjornson, Liesbet Van der Perre, Stefano Buzzi, Erik G. Larsson,
% “Massive MIMO in Sub-6 GHz and mmWave: Physical, Practical, and Use-Case
% Differences,” IEEE Wireless Communications, vol. 26, no. 2, pp. 100-108,
% April 2019.   
%
% Download article: https://arxiv.org/pdf/1803.11023
%
% This is version 1.0 (Last edited: 2018-03-08)
%
% License: This code is licensed under the GPLv2 license. If you in any way
% use this code for research that results in publications, please cite our
% paper as described above.


%Empty workspace and close figures
close all;
clear;


%Set the baseline uplink SNR in Case 1
SNR_original = 10;

%Set the baseline coherence block length in Case 1
tau_original = 40000;


%% Case 1: 3 GHz, 50 MHz bandwidth

%Set the uplink SNR
SNR_ul = SNR_original;

%The downlink SNR is 100 times higher due to higher power
SNR_dl = SNR_ul*100;

%Bandwidth in MHz
B = 50;

%Set the baseline coherence block length
tau = tau_original;

%Set the range of number of antennas
M = round(logspace(1,5,100));

%Set the range of number of users
K = round(logspace(1,5,100));


%Compute the SE
sumSE_3GHz = zeros(length(K),length(M));

for n = 1:length(M)

    cCSI = 1./(1+1./(K*SNR_ul));

    sumSE_3GHz(:,n) = B*K.*(1-K/tau).*log2(1+M(n)*(SNR_dl./K).*cCSI/(SNR_dl+1));

end

sumSE_3GHz(sumSE_3GHz<0) = NaN; %Remove the cases where (1-K/tau)<0


%% Plot Figure 5(a)
figure;
surf(K,M,sumSE_3GHz'/1000);
xlabel('Number of UEs ($K$)','Interpreter','Latex');
ylabel('Number of antennas ($M$)','Interpreter','Latex');
zlabel('Sum rate [Gbit/s]','Interpreter','Latex');
colormap(hot);
view([-22 28]);



%% Case 2: 60 GHz, 1000 MHz bandwidth

%This factor represents that we have 20 times higher frequency and 20 times
%more bandwidth
freqFactor = 20;

%Set the uplink SNR, which is 1/freqFactor^2 smaller due to the smaller
%antenna area and 1/freqFactor smaller due to the larger bandwidth
SNR_ul = SNR_original/freqFactor^3;

%The downlink SNR is 100 times higher due to higher power
SNR_dl = SNR_ul*100;

%Bandwidth in MHz
B = 50*freqFactor;

%Compute the new coherence block due to a smaller coherence time
tau = tau_original/freqFactor;

%Set the range of number of antennas
M = round(logspace(1,5,100));

%Set the range of number of users
K = round(logspace(1,5,100));


%Compute the SE
sumSE_60GHz = zeros(length(K),length(M));

for n = 1:length(M)

    cCSI = 1./(1+1./(K*SNR_ul));

    sumSE_60GHz(:,n) = B*K.*(1-K/tau).*log2(1+M(n)*(SNR_dl./K).*cCSI/(SNR_dl+1));

end

sumSE_60GHz(sumSE_60GHz<0) = NaN; %Remove the cases where (1-K/tau)<0


%% Plot Figure 5(b)
figure;
surf(K,M,sumSE_60GHz'/1000);
xlabel('Number of UEs ($K$)','Interpreter','Latex');
ylabel('Number of antennas ($M$)','Interpreter','Latex');
zlabel('Sum rate [Gbit/s]','Interpreter','Latex');
colormap(hot);
view([-22 28]);
