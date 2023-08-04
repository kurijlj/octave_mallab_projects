function BW = Segment_Film_Piece(ss)
    %% -------------------------------------------------------------------------
    %%
    %% Function: 'Segment_Film_Piece':
    %%
    %% -------------------------------------------------------------------------
    %
    %  Use:
    %       -- BW = Segment_Film_Piece(ss)
    %
    %% Description:
    %       Return binary mask of a film piece for each color channel from
    %       a Scanset object.
    %
    %       The function is used to segment a film piece from a Scanset object,
    %       for each color channel. The steps that are taken to segment
    %       the film piece or a optical density step wedge from the scanner
    %       background are:
    %           1.  Smooth the image with a Gaussian filter.
    %           2.  Subtract smoothed image from original image to get
    %               the unsharp mask.
    %           3.  Normalize the edges to the range [0, 1].
    %           4.  Apply unsharp mask to original image.
    %           5.  Calculate the image gradient of the edge enhanced image.
    %           6.  Apply iamge dilate to the gradient image.
    %           7.  Apply watershed segmentation to the dilated gradient image.
    %           8.  Apply image fill holes to the watershed segmented image.
    %           9.  Apply image erode to the filled image.
    %
    %       Function parameters:
    %       ss: Scanset object
    %           The Scanset object of the scanned film piece.
    %
    %       Return values:
    %       BW: matrix
    %           Binary mask of the film piece for each color channel.
    %
    % (C) Copyright 2023 Ljubomir Kurij
    %
    % --------------------------------------------------------------------------
    fname = "Segment_Film_Piece";
    use_case_a = sprintf(" -- BW = %s(ss)", fname);

    % Check input arguments ----------------------------------------------------

    % Check number of input arguments
    if nargin != 1
        error( ...
            "Invalid call to %s. Correct usage is:\n%s", ...
            fname, ...
            use_case_a ...
            );

    endif;  % if nargin != 1

    % Check type of input argument
    if(~isa(ss, 'Scanset'))
        error( ...
            '%s: ss must be an instance of the "Scanset" class', ...
            fname ...
            );
    
    endif;  % if !isa(ss, "Scanset")

    % Do the computation -------------------------------------------------------

    % Make a kernel for the Gaussian filter
    sigma = 2;  % Standard deviation of the Gaussian kernel
    % Calculate the size of the kernel based on the desired sigma value
    kernel_size = (2 * ceil(3 * sigma) + 1) .* [1 1];
    kernel = fspecial('gaussian', kernel_size, 2);

    % Calculate the smoothed image from the original pixel values
    smtd = imfilter(ss.pixel_data(), kernel, "symmetric");

    % Calculate the unsharp mask
    unsharp_mask = ss.pixel_data() - smtd;

    % Normalize the edges to the range [0, 1]
    unsharp_mask = mat2gray(unsharp_mask);

    % Apply the unsharp mask to the original image
    edge_enhanced = mat2gray(ss.pixel_data() .* unsharp_mask);

    % Calculate the image gradient of the edge enhanced image
    gradR = imgradient(edge_enhanced(:, :, 1));
    gradG = imgradient(edge_enhanced(:, :, 2));
    gradB = imgradient(edge_enhanced(:, :, 3));
    
    % Calculate mean pixel value for each gradient image
    meanR = mean2(gradR);
    meanG = mean2(gradG);
    meanB = mean2(gradB);

    % Threshold the gradient images
    grad_mask_R = gradR > meanR;
    grad_mask_G = gradG > meanG;
    grad_mask_B = gradB > meanB;

    % Dilate the resulting gradient image
    se = strel('disk', 1, 0);
    dilatedR = imdilate(grad_mask_R, se);
    dilatedG = imdilate(grad_mask_G, se);
    dilatedB = imdilate(grad_mask_B, se);

    % Apply watershed segmentation to the dilated gradient image
    watershedR = watershed(dilatedR);
    watershedG = watershed(dilatedG);
    watershedB = watershed(dilatedB);

    % Fill holes in the inverted watershed segmented image
    filledR = imfill(~watershedR, "holes");
    filledG = imfill(~watershedG, "holes");
    filledB = imfill(~watershedB, "holes");

    % Erode the filled image
    maskR = imerode(filledR, se);
    maskG = imerode(filledG, se);
    maskB = imerode(filledB, se);

    % Calculate the distance transform of the eroded image
    maskR = bwdist(maskR);
    maskG = bwdist(maskG);
    maskB = bwdist(maskB);

    % Discard all pixels that are closer than 3 pixels from the edge
    maskR = maskR >= 3;
    maskG = maskG >= 3;
    maskB = maskB >= 3;

    % Return the binary mask for each color channel
    mask = cat(3, maskR, maskG, maskB);
    clear maskR maskG maskB;

    % Smooth edges of the binary mask by applying a Gaussian filter
    sigma = 1;
    kernel_size = (2 * ceil(3 * sigma) + 1) .* [1 1];
    kernel = fspecial('gaussian', kernel_size, 2);
    mask = imfilter(mask, kernel, "symmetric");

    % Normalize the binary mask to the range [0, 1]
    mask = mat2gray(mask);

    % Threshold all pixels below 0.5 intensity
    mask = mask < 0.5;

    % Make a uninon of the binary masks for each color channel
    BW = mask(:, :, 1) | mask(:, :, 2) | mask(:, :, 3);

    % Return the binary mask for each color channel
    BW = cat(3, BW, BW, BW);

endfunction;  % function Segment_Film_Piece

% End of file Segment_Film_Piece.m