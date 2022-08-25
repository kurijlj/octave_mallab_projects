% -----------------------------------------------------------------------------
%
% Subfunction 'OkCancelPanelElementsPosition':
%
% Use:
%       -- position = okCancelPanelElementsPosition(hcntr, uistyle)
%
% Description:
%          Function to calculate GUI elements postion on the panel.
%
% -----------------------------------------------------------------------------
function position = okCancelPanelElementsPosition(hcntr, uistyle)
    fname = 'okCancelPanelElementsPosition';
    use_case_a = ' -- position = okCancelPanelElementsPosition(hcntr, uistyle)';

    % Validate input arguments ------------------------------------------------
    if(~ishghandle(hcntr))
        error( ...
            '%s: hcntr must be handle to a graphics object', ...
            fname
            );

    endif;

    if(~isa(uistyle, 'AppUiStyle'))
        error( ...
            '%s: uistyle must be an instance of the "AppUiStyle" class', ...
            fname ...
            );

    endif;

    % Get UI style parameters normalized to extents of the containing UI element
    nstyle = uistyle.normalized(getpixelposition(hcntr));

    % Calculate elements positions within container
    position = [];

    % Center buttons in the view
    nbtns = 2;
    idx = 1;
    while(nbtns >= idx)
        position = [ ...
            position; ...
            (1.00 - nstyle.btn_width)/2, ...
            % (1.00 - (nbtns*nstyle.btn_height + nstyle.padding_ver))/nbtns ...
            %     + (nbtns - idx)*nstyle.btn_height ...
            %     + (nbtns - idx)*nstyle.padding_ver, ...
            (1.00 - nstyle.padding_ver - nbtns*nstyle.btn_height)/nbtns ...
                + (nbtns - idx)*(nstyle.padding_ver + nstyle.btn_height), ...
            nstyle.btn_width, ...
            nstyle.btn_height; ...
            ];

        idx = idx + 1;

    endwhile;

endfunction;
