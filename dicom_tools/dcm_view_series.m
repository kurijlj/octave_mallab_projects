% 'dcm_view_series' is a function from the package: 'DICOM Toolbox'
%
%  -- dcm_view_series ()
%      TODO: Put function description and help here

function dcm_view_series()
    % Store function name into variable for easier lgo reporting and user
    % feedback management
    fname = 'dcm_view_series';

    series_dir = uigetdir('title', 'DICOM Series View');

    if(0 == series_dir(1))
        printf('%s: No directory selected.\n', fname);

        return;

    endif;

    series_file = readdir(series_dir);
    if(isempty(series_file))
        printf('%s: Nothing to load. Empty directory.\n', fname);

        return;

    endif;

    series_data = {};
    series_info = {};

    index = 3;
    progress_window = waitbar( ...
        0.0, ...
        'Loading DICOM data ...', ...
        'name', 'DICOM Series View' ...
        );
    while(length(series_file) >= index)
        path = fullfile(series_dir, series_file{index});
        if(isdicom(path))
            series_info = {series_info{:} dicominfo(path)};
            series_data = {series_data{:} dicomread(path)};

        else
            printf('%s: WARNING! Not a DICOM file: \"%s\".\n', fname, path);

        endif;

        waitbar(index/length(series_file), progress_window);
        index = index + 1;

    endwhile;

    % Clean up GUI
    if(ishandle(progress_window))
        delete(progress_window);

    endif;

    if(isempty(series_data))
        printf('%s: ERROR! Not enough data to reconstruct DICOM series.\n', fname, path);

        return;

    endif;

    hfig = figure('name', 'DICOM Series View', 'units', 'points');
    hax = axes('parent', hfig);
    hslsel = uicontrol( ...
        'parent', hfig, ...
        'style', 'slider', ...
        'units', 'points', ...
        'tag', 'slice_selector', ...
        'tooltipstring', 'Select slice', ...
        'callback', @dcm_update_series_view, ...
        'min', 1, 'max', length(series_data), ...
        'sliderstep', [ ...
            1/(length(series_data) - 1), ...
            1/(length(series_data) - 1) ...
            ], ...
        'value', 1 ...
        );

    % Calculate index of slice in the middle of the series and display it
    midsl_index = ceil(length(series_data)/2);
    blevel ...
        = series_info{midsl_index}.WindowCenter ...
        - series_info{midsl_index}.WindowWidth/2;
    tlevel ...
        = series_info{midsl_index}.WindowCenter ...
        + series_info{midsl_index}.WindowWidth/2;
    set(hslsel, 'value', midsl_index);
    imshow(series_data{midsl_index}, [blevel, tlevel], 'parent', hax);

    % Save GUI state
    hgui = guihandles(hfig);
    hgui.main_figure = hfig;
    hgui.hax_view = hax;
    hgui.hslsel = hslsel;
    hgui.series_data = series_data;
    hgui.series_info = series_info;
    hgui.itf = [blevel tlevel];
    guidata(hfig, hgui);

endfunction;


function dcm_update_series_view(obj)
    hgui = guidata(obj);

    switch(gcbo)
        case {hgui.hslsel}
            slindex = round(get(hgui.hslsel, 'value'));
            imshow(hgui.series_data{slindex}, hgui.itf, 'parent', hgui.hax_view);

    endswitch;

endfunction;
