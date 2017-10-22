function [messageRecu] = messageRecu(Usigal,M,m,C)
% m nombre de utilisateurs
% M longeurs de messages
% U codage utilise

Cu = C([3:3+m],:);
%Creer les sigaux emets de m ligne et M colome
Usigal = 2*randi([0 1],m,M)-1;

Ucodagedtotal = ones(m,M*length(C(1,:)));
Uemettotal = ones(m,M*length(C(1,:))/2);
for l = 1:m
    Ucodaged =[];
    %Signaux de m utilisateurs apres codage
    for c=1:M
        if(Usigal(l,c)== 1)
            Ucodaged = [Ucodaged C(l,:)];
        else
            Ucodaged = [Ucodaged -C(l,:)];
        end
    end
    Ucodagedtotal(l,:) = Ucodaged;
    %Signaux apres modulation
    Symbol = [1+1i,1-1i,-1-1i,-1+1i];
    Uemet = [];
    for iter=1:length(Ucodagedtotal(1,:))/2
        Uemet = [Uemet Ucodagedtotal(l,2*iter-1)+Ucodagedtotal(l,2*iter)*i];
    end  
    Uemettotal(l,:) = Uemet;
end

 %Ajout des bruits blanc
    Eb = 5/4;
    SNR = 6;
    No= Eb*10.^(-SNR/10);
    B = sqrt(No)*randn(m,length(Uemettotal(1,:)));
    Y = Uemettotal + B;
    messageRecu = Y;