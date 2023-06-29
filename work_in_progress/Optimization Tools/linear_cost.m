function C = linear_cost(x, theta1, theta2, y)
    [T1, T2] = meshgrid(theta1, theta2);
    n = length(theta1);
    m = length(theta2);
    C = zeros(n, m);
    for i = 1:n
        for j = 1:m
            C(i, j) = 1/(2*length(y)) * sum((T1(i, j) + T2(i, j)*x - y).^2);

        endfor;  % end of j loop

    endfor;  % end of i loop

endfunction;  % end of function