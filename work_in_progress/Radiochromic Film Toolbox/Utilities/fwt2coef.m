function result = fwt2coef(M, coef_str)
result = zeros(size(M, 1)/2, size(M, 2)/2);
if(isequal('LL', coef_str))
result = M(1:size(M, 1)/2, 1:size(M, 2)/2);
elseif(isequal('H', coef_str))
result = M(1:size(M, 1)/2, size(M, 2)/2:end);
elseif(isequal('V', coef_str))
result = M(size(M, 1)/2:end, 1:size(M, 2)/2);
else
result = M(size(M, 1)/2:end, size(M, 2)/2:end);
endif;
endfunction;
