% 'dcm_view_study' is a function from the package: 'DICOM Toolbox'
%
%  -- dcm_study_view()
%      TODO: Put function description and help here

function dcm_view_study()
    % Store function name into variable for easier lgo reporting and user
    % feedback management
    fname = 'dcm_view_study';

    study_dir = uigetdir();

    if(0 == study_dir(1))
        printf('%s: No directory selected.\n', fname);

        return;

    endif;

    study_file = readdir(study_dir);
    if(isempty(study_file))
        printf('%s: Nothing to load. Empty directory.\n', fname);

        return;

    endif;

    study = cell(length(study_file) - 2, 1);
    study_hist = cell(length(study_file) - 2, 1);
    study_desc = '';
    bins = [];
    study_min = ones(length(study_file) - 2, 1) * 65535;
    study_max = ones(length(study_file) - 2, 1) * 0;

    index = 3;
    error_read = 1;
    while(length(study_file) >= index)
        path = fullfile(study_dir, study_file{index});
        if(isdicom(path))
            study{index - 2} = dicomread(path);
            % [study_hist{index - 2}, bins] = rct_fast_hist_2D(study{index - 2}, 1024, 'CLI');
            study_min(index - 2) = min(min(study{index - 2}));
            study_max(index - 2) = max(max(study{index - 2}));

        else
            printf('%s: WARNING! Not a DICOM file: \"%s\".\n', fname, path);
            study{index - 2} = NaN;
            study_hist{index - 2} = NaN;
            error_read = error_read + 1;

        endif;

        index = index + 1;

    endwhile;

    if(length(study_file) == error_read)
        printf('%s: ERROR! Not enough data to reconstruct DICOM study.\n', fname, path);

        return;

    endif;

    hfig = figure('name', 'DICOM Study View', 'units', 'points');
    hax = axes('parent', hfig);

    % index = 1;
    % while(length(study_hist) >= index)
    %     hold(hax, 'on');
    %     stairs(hax, bins, study_hist{index});
    %     hold(hax, 'off');

    %     index = index + 1;

    % endwhile;
    midsl_indx = ceil(length(study)/2);
    blevel = double(min(study_min))/65535;
    tlevel = double(max(study_max))/65535;
    imshow(study{midsl_indx}, [blevel, tlevel], 'parent', hax);

endfunction;
