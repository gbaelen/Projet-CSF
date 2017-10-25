function [ autocorr ] = generateGold ( )
    NbChip = 1024;
    nbCode = 1;

    seed = [0 0 0 0 0 0 0 0 0 0];
    while sum(seed) == 0
        seed = randi([0 1], [1 10]);
    end

    g1_bit = seed;
    g2_bit = seed;

    code = zeros(nbCode, NbChip);
    for i=1:nbCode
        for j=1:NbChip
            %% G1
            g1_new = mod(g1_bit(3) + g1_bit(10),2);
            g1_out = g1_bit(10);

            %shift right
            g1_bit(2:end) = g1_bit(1:end-1);
            g1_bit(1) = g1_new;

            %% G2
            g2_new = mod(g2_bit(2) + g2_bit(3) + g2_bit(6) + g2_bit(8) + g2_bit(9) + g2_bit(10),2);
            g2_out = g2_bit(10);

            %shift right
            g2_bit(2:end) = g2_bit(1:end-1);
            g2_bit(1) = g2_new;

            %% somme
            code(i, j) = mod(g1_new + g2_new, 2);
        end
    end

    for i=1:NbChip
       if code(1, i) == 0
           code(1,i) = -1;
       end
    end

    %% autocorrélation
    autocorr = zeros(1, 1024);
    delayedCode = zeros(1, 1024);
    for i=1:NbChip-1
        delayedCode(1:i)= code(end-i+1:end);
        delayedCode(i+1:end) = code(1:end-i);
        autocorr(i) = autocorr(i) + sum(code(1, :).*delayedCode)/1024;
    end

%     delayedCode = zeros(1, 1024);
%     for i=1:NbChip
%         delayedCode(1:i)= code(end-i+1:end);
%         delayedCode(i+1:end) = code(1, 1:end-i);
%         autocorr(i) = autocorr(i) + sum(code(1, :).*delayedCode)/1024;
%     end
    %plot([-NbChip+1:NbChip], autocorr, '-');
end
