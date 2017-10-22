N=10;

hadamard_code = hadamard(64);
tmp_hadamard_table = hadamard_code;
message = zeros(2, N);

for utilisateur=1:N
    [row, column] = size(tmp_hadamard_table);
    hadamard_index = randi([3 row],[1 1]);
    code(utilisateur, :) = tmp_hadamard_table(hadamard_index, :);
    tmp_hadamard_table = tmp_hadamard_table([1:hadamard_index-1, hadamard_index+1:end],:);

    Bits = [ -1, 1 ];
    message_index = randi([0 1], [1 N]) + 1;
    message(utilisateur, :) = Bits(message_index);
end

encoded = zeros(N, 64);

for i=1:N
    for j=1:N
        encoded(i,:) = encoded(i,:) + message(j,i) .* code(j,:);
    end
end

decoded = zeros(N, N);

for j=1:N
    for i=1:N
        decoded(j, i) = sum(encoded(i,:).*code(j,:))/64;
    end
end

decoded