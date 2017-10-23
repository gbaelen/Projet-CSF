clear;
clc;
Nu = 1;
m = 1;
M = 2;
NBits = 1000;
SizeCode = 64;
NbChip = NBits*SizeCode;
SNR0 = 2;
SNR1 = 8;

message = zeros(Nu, NBits);
code = zeros(Nu, SizeCode);
message_encoded = zeros(1, NbChip);
message_bruite = zeros(Nu, NbChip);
received_message = zeros(1, NbChip);
received = zeros(1, NBits);
hadamard_code = hadamard(SizeCode);
tmp_hadamard_table = hadamard_code;

CONST = [-1, 1];
%%%%%%%%%%%%%%%%%%%%%%      Émission       %%%%%%%%%%%%%%%%%%%

for utilisateur=1:Nu

    %génération du message binaire
    Bits = [ -1, 1 ];
    message_index = randi([0 1], [1 NBits]) + 1;
    message(utilisateur, :) = Bits(message_index);

    %Récupération du code
    [row, column] = size(tmp_hadamard_table);
    hadamard_index = randi([3 row],[1 1]);
    code(utilisateur, :) = tmp_hadamard_table(hadamard_index, :);
    tmp_hadamard_table = tmp_hadamard_table([1:hadamard_index-1, hadamard_index+1:end],:);
end

%génération du message cod?
encoded = zeros(NBits, SizeCode);

for i=1:NBits
    for j=1:Nu
        encoded(i,:) = encoded(i,:) + message(j,i) .* code(j,:);
    end
end

message_encoded = reshape(encoded, [1 NbChip]);

Pe = [];
  for SNR = SNR0:SNR1
    %Bruitage canal
    for path=1:Nu
        %Génération du bruit
        Ph=0.8;
        Eb = 1/2*NBits;
        N0= Eb*10.^(-SNR/10);
        wk = sqrt(N0)*randn(1, NbChip);
        message_bruite = message_bruite + message_encoded + wk;
    end 

    %%%%%%%%%%%%%%%%%%%     Reception    %%%%%%%%%%%%%%%%%
    %Décodage Hadamard
    decoded = zeros(Nu, NBits);
    for j=1:Nu
        received = reshape(message_bruite(j,:), [NBits SizeCode]);
        for i=1:NBits
            decoded(j,i) = sum(received(i,:).*code(j,:))/64;
        end
    end

    for utilisateur=1:Nu
        %Récupération du signal et débruitage
         for k=1:NBits
            for l=1:M
                D(l) = (real(decoded(utilisateur, k))-real(CONST(l))).^2+(imag(decoded(utilisateur, k))-imag(CONST(l))).^2;
            end

            [X in] = min(D);
            message_dec(k) = CONST(in);
         end
        err = length(find(message_dec- message(utilisateur, :))~=0);
    end
    
    Pe = [Pe err/NBits];

  end
  
  
    figure('NAME','message_bruite');
    plot(real(message_bruite), imag(message_bruite), 'b');
  
    figure('NAME','messages decoded');
    plot(real(decoded), imag(decoded), '*');
    
    SNR = SNR0:SNR1
    EbNo=10.^(SNR/10);
    Ps=1.5*erfc(sqrt(2*EbNo/5));
    figure('NAME','Taux erreur'); 
    semilogy(SNR,Pe,'-o')
    hold on 
    semilogy(SNR,Ps,'-*')
    grid

