clear;
Nu = 10;
m = 1;
M = 2;
NBits = 10;
SizeCode = 64;
NbChip = NBits*SizeCode;

message = zeros(Nu, NBits);
code = zeros(Nu, SizeCode);
message_encoded = zeros(1, NbChip);
message_bruite = zeros(Nu, NbChip);
received_message = zeros(Nu, NBits);
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

%génération du message codé
encoded = zeros(NBits, SizeCode);

for i=1:NBits
    for j=1:Nu
        encoded(i,:) = encoded(i,:) + message(j,i) .* code(j,:);
    end
end

message_encoded = reshape(encoded, [1 NbChip]);
 
%envoie de tous les signaux simultanément
%Bruitage canal
for utilisateur=1:Nu
    %Génération du bruit
    Eb = 1;
    SNR = 40;
    N0 = Eb * 10^(-SNR/10);
    wk = sqrt(N0)*randn(1, NbChip);
    message_bruite(utilisateur, :) = message_encoded + wk;
end

%%%%%%%%%%%%%%%%%%%     Reception    %%%%%%%%%%%%%%%%%
%Décodage Hadamard
decoded = zeros(NBits, SizeCode);
for j=1:Nu
    received = reshape(message_bruite(Nu,:), [NBits SizeCode]);
    for i=1:NBits
        decoded(j, i) = sum(received(i,:).*code(j,:))/64;
    end
end
    
for utilisateur=1:Nu
    %Récupération du signal et débruitage
    figure(1);
    plot(real(decoded(utilisateur, :)), imag(decoded(utilisateur,:)), '*');
    for k=1:NBits
        for l=1:M
            D(l) = abs((decoded(utilisateur, k)) - CONST(l));
        end

        [X in] = min(D);
        message_dec(k) = CONST(in);
    end

    figure(2);
    plot(real(message_dec), imag(message_dec), '*');

    err = 0;
    for i=1:NBits
        if message_dec(i) ~= message(utilisateur, i)
            err = err + 1;
        end
    end

    err
end