% -----------------------------------------------------------------------------
%
% Subfunction 'itemViewElementsPosition':
%
% Use:
%       -- position = itemViewElementsPosition(hcntr, uistyle)
%
% Description:
%          Function to calculate GUI elements postion on the panel.
%
% -----------------------------------------------------------------------------
function position = itemViewElementsPosition(hcntr, uistyle)
    fname = 'itemViewElementsPosition';
    use_case_a = ' -- position = itemViewElementsPosition(hcntr, uistyle)';

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

    % Organize fields and labels the vertical stack. Align to the top of
    % the view
    nflds = 2;
    idx = 1;
    while(nflds >= idx)
        offset = 1 - 2*idx*(nstyle.padding_ver + nstyle.row_height);
        position = [ ...
            position; ...
            % Calculate position for the label
            nstyle.padding_hor, ...
            offset + nstyle.row_height, ...
            1.00 - 2*nstyle.padding_hor, ...
            nstyle.row_height; ...
            % Calculate position for the field
            nstyle.padding_hor, ...
            offset, ...
            1.00 - 2*nstyle.padding_hor, ...
            nstyle.row_height; ...
            ];
        idx = idx + 1;

    endwhile;

endfunction;
