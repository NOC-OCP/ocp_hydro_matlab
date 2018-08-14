x = [-20 0.  1 2 10];
x = x(:);

y = -2 + 3*x + x.*x;

y = y+0*randn(size(x));

V = [ones(length(x),1) x x.*x];
[Q R] = qr(V,0);
p = R\(Q'*y);

p


