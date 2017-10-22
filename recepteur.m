% Y est le sigal recu e
% m est le type de modulation
% U est le codage par le emeteur
function[result] = recepteur(Y,m,U)
% Y = U1emet;
% U=U1hadamard;
% m=2;
N = length(Y);
Symbol = [1+1i,1-1i,-1-1i,-1+1i];
r = [1:1:N];
for k=1:N
    for q=1:1:m
        Dk(q)=(real(Y(k))-real(Symbol(q))).^2+(imag(Y(k))-imag(Symbol(q))).^2;
    end
        [V,I]=min(Dk');
        r(k) = Symbol(I);
end
rdecodage = [];
for iter = 1:length(r)
    rdecodage = [rdecodage real(r(iter)) imag(r(iter))];
end
rdemodule = [];
for iter = 0:length(rdecodage)/length(U)-1
    if(rdecodage(iter*length(U)+1:iter*length(U)+length(U))==U)
        rdemodule=[rdemodule 1];
    else 
        rdemodule=[rdemodule -1];
    end 
end
result = rdemodule;
