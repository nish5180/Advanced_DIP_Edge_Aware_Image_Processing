function R = lapfilter_core(I, r_func, nlev,s,alpha,beta)
% I      : full-resolution grayscale image (double, [0,1])
% r_func : remapping function handle @(patch, guide) → remapped patch
% nlev   : number of pyramid levels

% Step 1: Gaussian pyramid of input
G = create_gaussian_pyramid(I, nlev);

% Step 2: Prepare empty Laplacian output pyramid
L_out = cell(nlev, 1);
for l = 1:nlev
    L_out{l} = zeros(size(G{l}));
end

% Step 3: Loop through all coefficients
for l = 1:nlev-1
    [rows, cols] = size(G{l});

    for y = 1:rows
        for x = 1:cols

            g = G{l}(y, x);
            fprintf("Guide value at (%d, %d, level %d): %.4f\n", x, y, l, g);

            % 3.2 Subregion and center from full-res image
            [R, center] = determine_subregion_symmetric_padding(I, l, x, y);
            % [Rh, Rw] = size(R);
            % fprintf("Subregion size: %dx%d | Center: (%d, %d)\n", Rh, Rw, center(1), center(2));

            % 3.3 Remap patch using guide
            R_remapped = r_func(R, g);

            % 3.4 Laplacian pyramid of remapped patch
            L_patch = construct_laplacian_pyramid(R_remapped, nlev);
            % DEBUG
            if x == 10 && y == 22 && l == 4
                figure;
                subplot(1,3,1); imshow(R); title('Original Patch');
                subplot(1,3,2); imshow(R_remapped); title('Remapped Patch');
                subplot(1,3,3); imshow(R - R_remapped, []); title('Difference');
            end          

            % 3.5 Extract and assign the coefficient if within bounds
            if l <= length(L_patch)
                [ph, pw] = size(L_patch{l});
                cy = center(1);
                cx = center(2);

                % cy = floor((y_f - ymin) / scale) + 1;
                % cx = floor((x_f - xmin) / scale) + 1;


                if cy <= ph && cx <= pw
                    L_out{l}(y, x) = L_patch{l}(cy, cx);
                    fprintf("l=%d (x=%d,y=%d): inserted %.4f from patch[%d,%d]\n", l, x, y, L_patch{l}(cy, cx), cy, cx);

                    %fprintf("Inserted coefficient at (%d,%d) = %.4f\n", y, x, L_patch{l}(cy, cx));

                end
            end
        end
    end
end

% Step 4: Final residual
%original
L_out{nlev} = G{nlev};

% Step 4: Final level remapping
%this is a new tryout, can be remove dif it doesnt work
% R_remapped = remapping_function(G{nlev}, G{nlev}, s, alpha, beta);  % full-resolution remapping
% L_patch = construct_laplacian_pyramid(R_remapped, nlev);
% L_out{nlev} = L_patch{nlev};


% Step 5: Collapse pyramid
R = collapse_laplacian_pyramid(L_out);
R = min(max(R, 0), 1); % Clamp to [0, 1]
end


% function R = lapfilter_core(I, r_func, nlev)
% % I      : full-resolution grayscale image (double, [0,1])
% % r_func : remapping function handle @(patch, guide) → remapped patch
% % nlev   : number of pyramid levels
% 
% % Step 1: Gaussian pyramid of input
% G = create_gaussian_pyramid(I, nlev);
% 
% % Step 2: Prepare empty Laplacian output pyramid
% L_out = cell(nlev, 1);
% for l = 1:nlev
%     L_out{l} = zeros(size(G{l}));
% end
% 
% % Step 3: Loop through all coefficients
% for l = 1:nlev-1
%     [rows, cols] = size(G{l});
%     scale = 2^(l - 1);
%     h = 3 * scale - 2;  % half-width of patch
% 
%     for y = 1:rows
%         for x = 1:cols
%             % Full-resolution location corresponding to (x, y) at level l
%             x_f = (x - 1) * scale + 1;
%             y_f = (y - 1) * scale + 1;
% 
%             % Define patch bounds in full-res space
%             [H, W] = size(I);
%             xmin = max(1, x_f - h);
%             xmax = min(W, x_f + h);
%             ymin = max(1, y_f - h);
%             ymax = min(H, y_f + h);
% 
%             % Extract patch
%             R = I(ymin:ymax, xmin:xmax);
% 
%             % Remap patch using local guide from pyramid
%             g = G{l}(y, x);
%             R_remapped = r_func(R, g);
% 
%             % Build Laplacian pyramid of remapped patch
%             L_patch = construct_laplacian_pyramid(R_remapped, nlev);
% 
%             % Compute full-res center of remapped patch
%             yfc = y_f - ymin + 1;
%             xfc = x_f - xmin + 1;
% 
%             % Convert to coordinates in level l
%             yfclev = floor((yfc - 1) / scale) + 1;
%             xfclev = floor((xfc - 1) / scale) + 1;
% 
%             % Insert coefficient if within bounds
%             [ph, pw] = size(L_patch{l});
%             if yfclev <= ph && xfclev <= pw
%                 L_out{l}(y, x) = L_patch{l}(yfclev, xfclev);
%             end
%         end
%     end
% end
% 
% % Step 4: Final residual
% L_out{nlev} = G{nlev};
% 
% % Step 5: Collapse pyramid
% R = collapse_laplacian_pyramid(L_out);
% R = min(max(R, 0), 1); % Clamp to [0, 1]
% end
