clear;
clc;
Nu =6;
m = 1;
M = 2;
NBits = 50000;
SizeCode = 64;
NbChip = NBits*SizeCode;
Ph = 1;
Eb = Ph*SizeCode/2;

CONST = [-1, 1];

iter = 1;
for SNR=1:8
    
message = zeros(Nu, NBits);
code = zeros(Nu, SizeCode);
message_encoded = zeros(1, NbChip);
received_message = zeros(1, NbChip);
received = zeros(1, NBits);
hadamard_code = hadamard(SizeCode);
tmp_hadamard_table = hadamard_code;    
    
err = 0;
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
    
    %canal de rayleigh
    t0 = 2*10^(-6);
    nb_path = 8;
    Te=t0/nb_path;
    for coef=1:nb_path
        P(coef) = (2/t0)*(2 -((2*coef)*(Te/t0)));
        sigma = P(coef)/2;
        h(coef) = sqrt(sigma)*randn(1, 1);
    end

    %Bruitage canal
    N0 = Eb * 10^(-SNR/10);
    wp = sqrt(N0)*randn(1, NbChip);
    wq = sqrt(N0)*randn(1, NbChip);
    wk = wp;

    message_bruite = message_encoded + wk;


 %%%%%%%%%%%%%%%%%%%     Reception    %%%%%%%%%%%%%%%%%
    %Décodage Hadamard
    decoded = zeros(Nu, NBits);
    user_index = 1;
    received = reshape(message_bruite, [NBits SizeCode]);
    for j=1:Nu
        for i=1:NBits
            decoded(j, i) = sum(received(i,:).*code(user_index,:))/SizeCode;
        end
    end

    %Récupération du signal et débruitage
    for k=1:NBits
        for l=1:M
            D(l) = abs((decoded(user_index, k)) - CONST(l));
        end

        [X in] = min(D);
        message_dec(k) = CONST(in);
    end

    for i=1:NBits
        if message_dec(i) ~= message(user_index, i)
            err = err + 1;
        end
    end
    Ps(iter)= err/NBits;
    Q(iter) = 0.5*erfc(sqrt(Eb/N0));
    ebno(iter)=SNR;
    iter = iter+1;
end


figure(3);
semilogy(ebno, Ps, '-s');
hold on;
semilogy(ebno, Q, '-k');
grid on;