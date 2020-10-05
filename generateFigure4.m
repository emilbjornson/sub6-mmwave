% This Matlab script generates Figure 4 in the paper:
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


%Carrier frequency (Hz)
carrierCenter = 60e9;

%Speed of light (m/s)
speedoflight = 299792458;

%Center wavelength
lambdaCenter = speedoflight/carrierCenter;

d_H = 0.5*lambdaCenter; %Horizontal antenna spacing
d_V = 0.5*lambdaCenter; %Vertical antenna spacing


%Define array setups (Horizontal versus vertical)
arraySetups = [32 32; 64 64; 128 128];


%Maximum bandwidth
maxBandwith = 2e9;

%Compute frequency range around the center frequency
frequencyRange = linspace(carrierCenter-maxBandwith/2, carrierCenter+maxBandwith/2,101);


%LoS angles to the user
varphi_LoS = pi/4;
theta_LoS = -pi/4;


%NLoS angles to the user
varphi_NLoS = [pi/6 pi/3 pi/4 pi/4 pi/12];
theta_NLoS = [-pi/5 -pi/5 -pi/6 -pi/12 -pi/6];


%Prepare to compute array gain
arraygain = zeros(length(frequencyRange),size(arraySetups,1));
maxgain = zeros(1,size(arraySetups,1));


%Go through all array setups
for l = 1:size(arraySetups,1)
    
    
    % Define array
    M_H = arraySetups(l,1); %Number of antennas per horizontal row
    M_V = arraySetups(l,2); %Number of rows
    
    %Define the antenna geometry
    M = M_H*M_V; %Total number of antennas
    U = zeros(3,M); %Matrix containing the position of the antennas
    
    i = @(m) mod(m-1,M_H); %Horizontal index
    j = @(m) floor((m-1)/M_H); %Vertical index
    
    for m = 1:M
        U(:,m) = [0; i(m)*d_H; j(m)*d_V]; %Position of the m:th element
    end
    
    
    %Compute array response at the center frequency
    arrayresponse = functionSpatialSignature3DLoS(U,varphi_LoS,theta_LoS,lambdaCenter);
    
    for j = 1:length(varphi_NLoS)
        
        arrayresponse = arrayresponse + functionSpatialSignature3DLoS(U,varphi_NLoS(j),theta_NLoS(j),lambdaCenter)/length(varphi_NLoS);
        
    end
    
    
    %Keep the phases
    beamforming = exp(1i*angle(arrayresponse));
    
    
    %Maximum array gain
    maxgain(l) = norm(beamforming)^2;
    
    
    %Go through other frequencies in the range
    for n = 1:length(frequencyRange)
        
        %Wavelength at the considered frequency
        lambda = speedoflight/frequencyRange(n);
        
        %Compute array response at the considered frequency
        arrayresponse = functionSpatialSignature3DLoS(U,varphi_LoS,theta_LoS,lambda);
        
        for j = 1:length(varphi_NLoS)
            
            arrayresponse = arrayresponse + functionSpatialSignature3DLoS(U,varphi_NLoS(j),theta_NLoS(j),lambda)/length(varphi_NLoS);
            
        end
        
        arrayresponse = arrayresponse/norm(arrayresponse);
        
        
        %Compute the array gain that is obtained with the beamforming
        arraygain(n,l) = abs(arrayresponse'*beamforming).^2;
        
    end
    
end



%% Plot the simulation results
figure;
hold on; box on;
plot(frequencyRange/1e9,100*arraygain(:,1)/maxgain(1),'k--','LineWidth',1);
plot(frequencyRange/1e9,100*arraygain(:,2)/maxgain(2),'b-','LineWidth',1);
plot(frequencyRange/1e9,100*arraygain(:,3)/maxgain(3),'r-.','LineWidth',1);

xlabel('Frequency [GHz]');
ylabel('Percentage of the maximum array gain (%)');
ylim([0 100]);
legend({'$32 \times 32$','$64 \times 64$','$128 \times 128$'},'Location','Best','Interpreter','Latex');
