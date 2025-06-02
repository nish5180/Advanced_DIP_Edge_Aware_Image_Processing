function [R, center] = determine_subregion_symmetric_padding(I, level, x0, y0)
% Extracts a subregion R from the full-res image I centered on the location
% corresponding to (x0, y0) at pyramid level `level`.
% Returns the patch R and the center index at the target level.

    % Scale factor between pyramid level and full-resolution
    scale = 2^(level - 1);

    % Half-width of patch based on 5-tap kernel support (from paper)
    h = 3 * scale - 2;

    % Pad the original image symmetrically to handle edges
    I_pad = padarray(I, [h h], 'symmetric');

    % Compute full-resolution coordinates in padded image
    x_f = (x0 - 1) * scale + 1 + h;
    y_f = (y0 - 1) * scale + 1 + h;

    % Extract patch from padded image
    xmin = x_f - h;
    xmax = x_f + h;
    ymin = y_f - h;
    ymax = y_f + h;

    R = I_pad(ymin:ymax, xmin:xmax, :);

    % Center index in patch (still full-resolution)
    y_center_full = y_f - ymin + 1;
    x_center_full = x_f - xmin + 1;

    % Convert center to current pyramid level coordinates
    center_y = floor((y_center_full - 1) / scale) + 1;
    center_x = floor((x_center_full - 1) / scale) + 1;

    center = [center_y, center_x];  % return as (row, col)
end
