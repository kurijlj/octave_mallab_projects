function MF = thresh_merit(PD, s)
    MF = zeros(numel(0:s:65535), 3);
    for i = 0:s:65535
        RED  = PD(:, :, 1);
        GRN  = PD(:, :, 2);
        BLU  = PD(:, :, 3);
        REDM = PD(:, :, 1) < i;
        GRNM = PD(:, :, 2) < i;
        BLUM = PD(:, :, 3) < i;
        MF(i+1, 1) = sum(sum(REDM)) / numel(PD(:, :, 1));
        MF(i+1, 2) = sum(sum(GRNM)) / numel(PD(:, :, 2));
        MF(i+1, 3) = sum(sum(BLUM)) / numel(PD(:, :, 3));
        % MF(i+1, 1) = sum(sum(REDM)) / sum(sum(~REDM));
        % MF(i+1, 2) = sum(sum(GRNM)) / sum(sum(~REDM));
        % MF(i+1, 3) = sum(sum(BLUM)) / sum(sum(~REDM));
    endfor;
endfunction;
