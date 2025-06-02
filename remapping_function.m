function out = remapping_function(I, g, sigma_r, alpha, beta)
% Input:
%   I: Grayscale image (single-precision, range [0,1])
%   sigma_r: Detail/edge threshold (scalar)
%   alpha: Detail remapping exponent (alpha <= 1 smooths, alpha > 1 sharpens)
%   beta: Edge scaling factor (beta < 1 compresses, beta > 1 expands dynamic range)

% 1. Initialize

out = zeros(size(I), 'like', I);
noise_level = 0.01;  % From original paper

if alpha ~= 1 || beta ~= 1
    fprintf("Mean remapping change: %.6f\n", mean(abs(out(:) - I(:))));
end

% 2. Compute pixel-wise difference
diff = I - g;
abs_diff = abs(diff);
fprintf("Max |I - g| = %.4f\n", max(abs_diff(:)));


% 3. Smooth transition for alpha < 1 (Eq. 3 in paper) LATEST CHANGE COMMENT
% 
if alpha < 1
    tau = smooth_step(noise_level, 2*noise_level, abs_diff*sigma_r);
else
    tau = 0;
end



% tau = ones(size(I), 'like', I);  % default to identity when alpha = 1
% if alpha < 1
%     tau = smooth_step(noise_level, 2*noise_level, abs_diff * sigma_r);
% end


% 4. Detail remapping (|i-g| ≤ sigma_r)
is_detail = abs_diff <= sigma_r;
d = abs_diff(is_detail) / sigma_r;  % Normalized detail [0,1]

% Apply f_d(d) = d^alpha with smooth transition
if alpha < 1
    fd = tau(is_detail).*(d.^alpha) + (1-tau(is_detail)).*d;
else
    fd = d.^alpha;
end

if alpha > 1
   disp("DETAIL SHARPENING ACTIVE")
end

%latest comment out
% out(is_detail) = g + sign(diff(is_detail)).*sigma_r.*fd;

if isscalar(g)
    out(is_detail) = g + sign(diff(is_detail)) .* sigma_r .* fd;
else
    out(is_detail) = g(is_detail) + sign(diff(is_detail)) .* sigma_r .* fd;
end



% 5. Edge remapping (|i-g| > sigma_r)
is_edge = ~is_detail;
a = abs_diff(is_edge) - sigma_r;  % Edge amplitude above threshold


%Debugging step
if alpha == 1 && beta == 1
    maxerr = max(abs(out(:) - I(:)));
    fprintf("Max remapping error at identity: %.6f\n", maxerr);
end


% Apply f_e(a) = beta*a (linear edge scaling)
fe = beta * a;
%latest comment out 12.01

% out(is_edge) = g + sign(diff(is_edge)).*(fe + sigma_r);

if isscalar(g)
    out(is_edge) = g + sign(diff(is_edge)) .* (fe + sigma_r);
else
    out(is_edge) = g(is_edge) + sign(diff(is_edge)) .* (fe + sigma_r);
end





if alpha > 1
    mean_detail = mean(abs_diff(is_detail));
    mean_edge = mean(abs_diff(is_edge));
    fprintf("  Mean |I-g| (detail): %.6f, (edge): %.6f\n", mean_detail, mean_edge);
end


% 6. Clamp to valid range
out = max(0, min(1, out));

end

% Smooth step function (from original paper)
function y = smooth_step(xmin, xmax, x)
    y = (x - xmin)/(xmax - xmin);
    y = max(0, min(1, y));
    y = y.^2 .* (3 - 2*y); 
end