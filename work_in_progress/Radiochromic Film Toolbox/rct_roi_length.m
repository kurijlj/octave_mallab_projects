%'rct_roi_length' is a function from the package: 'Radiochromic Film Toolbox'
%
% -- RL = rct_roi_length (dpi, l)
%     Calculate linear length of ROI square side.
%
%     For the given dpi and ROI square side length in milimeters calculate the
%     ROI square side length in points (i.e. pixels).
%
%     See also:

function RL = rct_roi_length(dpi, l)
    % First calculate half-length
    RL = floor((l*dpi)/50.8);

    % Then calculate full length by multiplying by two. This ensures that ROI
    % length is always an even number
    RL = 2*RL;

endfunction;
