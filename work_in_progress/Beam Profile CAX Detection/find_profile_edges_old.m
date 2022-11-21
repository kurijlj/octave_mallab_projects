function derr = find_profile_edges(x, Dp)
    idx = 2;
    derr = zeros(size(Dp));

    while(size(Dp, 1) - 1>= idx)
        c = polyfit( ...
            [x(idx-1), x(idx), x(idx+1)], ...
            [Dp(idx-1), Dp(idx), Dp(idx+1)], ...
            2 ...
            );
        x1 = x(idx) - (x(idx) - x(idx-1))/2;
        x2 = x(idx) + (x(idx+1) - x(idx))/2;
        dp1 = c(1)*x1^2 + c(2)*x1 + c(3);
        dp2 = c(1)*x2^2 + c(2)*x2 + c(3);
        derr(idx, 1) = (dp2 - dp1) / (x2 - x1);

        ++idx;

    endwhile;

    derr(1) = derr(2);
    derr(end) = derr(end - 1);
    derr = interp1(x, derr, x, 'spline');

endfunction;
