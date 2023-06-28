function M = matfun(xrange, yrange, Fz)
    [X, Y] = meshgrid(xrange, yrange);
    M = Fz(X, Y);

end