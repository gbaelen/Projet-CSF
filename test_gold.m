NbChip = 64;
nbCode = 2;

seed = randi([0 1], [1 10]);
g1_bit = seed;
g2_bit = seed;

code = zeros(nbCode, NbChip);
for i=1:nbCode
    for j=1:NbChip
        %% G1
        g1_new = mod(1 + g1_bit(3) + g1_bit(10),2);
        g1_out = g1_bit(10);

        %shift right
        g1_bit(2:end) = g1_bit(1:end-1);
        g1_bit(1) = g1_out;

        %% G2
        g2_new = mod(1 + g2_bit(2) + g2_bit(3) + g2_bit(6) + g2_bit(8) + g2_bit(9) + g2_bit(10),2);
        g2_out = g2_bit(10);

        %shift right
        g2_bit(2:end) = g2_bit(1:end-1);
        g2_bit(1) = g2_out;

        code(i, j) = mod(g1_out + g2_out, 2);
    end
end

for i=1:nbCode
    for j=1:NbChip
        if code(i,j) == 0
            code(i,j) = -1;
        end
    end
end

sum(code(1,:).*code(2,:))/64
sum(code(1,:).*code(1,:))/64