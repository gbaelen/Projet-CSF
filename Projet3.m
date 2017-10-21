clear;
N =64;
M = 32;
%Creer les sigaux emets
U1sigal = 2*randi([0 1],m,M)-1;
%Creer les codages hadamard 64
U = hadamard(N);
messageRecu = messageRecu(M,4,U);
messagerecepteur =ones(4,length(messageRecu(1,:)));
for iter = 1:4
messagerecepteur(iter,:) = recepteur(messageRecu(iter),2,U);
end
Err = sum(-messagerecepteur);
%Le utilisateur 3 utilise le premier ligne de codages hadamard 64 

%Ajout des bruits blanc
% Eb = 5/4;
% SNR = 6;
% No= Eb*10.^(-SNR/10);
% B1 = sqrt(No)*randn(1,length(U1emet));
% Y1 = U1emet + B1;
% %plot
% plot([1:M],U1sigal);
% figure(1);
% %hold on;
% plot([1:length(U1codaged)],U1codaged);
% figure(2);
% %hold on;
% plot([1:length(U1emet)],U1emet);
% figure(3);
% %hold on;
% plot([1:length(Y1)],Y1);
