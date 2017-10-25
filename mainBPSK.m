clear;
clc;
hold off;

Nu =1;
m = 1;
M = 2;
NBits = 1024;
SizeCode = 64;
NbChip = NBits*SizeCode;
Ph = 1;
Eb = Ph*SizeCode/2;
Ph_R = 0.8;
Eb_R = Ph_R*SizeCode/2;
branch=4;

trameSize = 1024;
CONST = [-1, 1];

gold_code = generateGold();

iter = 1;
for SNR=1:8
    
    message = zeros(Nu, NBits);
    code = zeros(Nu, SizeCode);
    message_encoded = zeros(1, NbChip);
    received_message = zeros(1, NbChip);
    received = zeros(1, NBits);
    hadamard_code = hadamard(SizeCode);
    tmp_hadamard_table = hadamard_code;   
    
    user_index = 1;
    AWGN_err = 0;
    Rayleigh_err = 0;
    %%%%%%%%%%%%%%%%%%%%%%      Émission       %%%%%%%%%%%%%%%%%%%

    for utilisateur=1:Nu
        %Génération du message binaire
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
    
    %découpage du message en trames de trameSize bits
    trame = zeros(NbChip/trameSize, trameSize);
    nbTrame = 0;
    for i=1:trameSize:NbChip
        nbTrame = nbTrame + 1;
        trame(nbTrame,:) = message_encoded(i:i+trameSize-1) .* gold_code;
    end
    
                                    %% Canal Rayleigh
    
    % canal de rayleigh
    t0 = 2*10^(-6);
    nb_path = 4;
    Te=t0/nb_path;   
    for coef=1:nb_path
        P(coef) = (2/t0)*(2 -((2*coef)*(Te/t0)));
        sigma = P(coef)/2;
        C1(coef) = sqrt(sigma)*randn(1, 1);
        C2(coef) = sqrt(sigma)*randn(1, 1);

        Co(coef) = C1(coef) + 1i*C2(coef);
    end
                                    
    received_Y = zeros(1, NbChip);
    
    N0_R = Eb_R * 10^(-SNR/10);
    wk = sqrt(N0_R)*randn(1, NbChip) + 1i.*sqrt(N0_R)*randn(1, NbChip);
    
    for i=0:nbTrame-1
        t = trame(i+1,:);
        Y = filter(Co, 1, t);
 
        %%%%%%%%%%%%%%%%%%%     Reception    %%%%%%%%%%%%%%%%%
        %récupération des trames
        received_Y(i*trameSize+1:i*trameSize+trameSize) = Y;
    end
    
    received_Y_bruite = received_Y + wk;
    
    % RAKE MRC
        % Maximum in h
    [sortedValues,sortIndex] = sort(Co(:),'descend');
    maxCoef = sortedValues(1:branch);
     
        % MRC
    Y_message = zeros(1, NBits);
    for i=1:branch
        alpha = abs(Co(i))*exp(-1i*angle(Co(i)));
        delayedCode = zeros(1, 1024);
        delayedCode(i:end) = gold_code(1:end-i+1);
        if i > 1
            delayedCode(1:i-1) = gold_code(end-i+2:end);
        end

        %Dégoldage
        degolded_Y = zeros(nbTrame,trameSize);
        gold_message_Y = reshape(received_Y_bruite, [nbTrame trameSize]);
        for i=1:nbTrame
            degolded_Y(i,:) = gold_message_Y(i,:).*delayedCode;
        end
        
        message_degolded = reshape(degolded_Y, [1 NbChip]);
        
        %Décodage Hadamard
        decoded_Y = zeros(Nu, NBits);
        message_Y = reshape(message_degolded, [NBits SizeCode]);
        for j=1:Nu
            for i=1:NBits
                decoded_Y(j, i) = sum(message_Y(i,:).*code(user_index,:))/64;
            end
        end
        
        Y_message = Y_message + decoded_Y.*alpha;
    end

    %Récupération du signal et débruitage
    for k=1:NBits
        for l=1:M
            D(l) = abs((Y_message(user_index, k)) - CONST(l));
        end

        [X in] = min(D);
        Y_dec(k) = CONST(in);
    end

    for i=1:NBits
        if Y_dec(i) ~= message(user_index, i)
            Rayleigh_err = Rayleigh_err + 1;
        end
    end
    
                                %% Canal AWGN
    %Bruitage reception
    N0 = Eb * 10^(-SNR/10);
    wp = sqrt(N0)*randn(1, NbChip);

    message_bruite = message_encoded + wp;
    %Décodage Hadamard awgn
    decoded = zeros(Nu, NBits);
    received = reshape(message_bruite, [NBits SizeCode]);
    for j=1:Nu
        for i=1:NBits
            decoded(j, i) = sum(received(i,:).*code(user_index,:))/SizeCode;
        end
    end

    %%Récupération du signal et débruitage
    for k=1:NBits
        for l=1:M
            D(l) = abs((decoded(user_index, k)) - CONST(l));
        end

        [X in] = min(D);
        message_dec(k) = CONST(in);
    end

    for i=1:NBits
        if message_dec(i) ~= message(user_index, i)
            AWGN_err = AWGN_err + 1;
        end
    end
    
    %% Calcul d'erreur 
    Ps_AWGN(iter)= AWGN_err/NBits;
    Ps_Rayleigh(iter)= Rayleigh_err/NBits;
    Q(iter) = 0.5*erfc(sqrt(Eb/N0));
    ebno(iter)=SNR;
    iter = iter+1;
end


figure(1);
semilogy(ebno, Ps_AWGN, '-s');
hold on;
semilogy(ebno, Q, '-k');
semilogy(ebno, Ps_Rayleigh, '-o');
grid on;