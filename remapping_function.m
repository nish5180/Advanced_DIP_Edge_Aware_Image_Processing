function out = remapping_function(I, g, sigma_r, alpha, beta)
% Input:
%   I: Grayscale image (single-precision, range [0,1])
%   sigma_r: Detail/edge threshold (scalar)
%   alpha: Detail remapping exponent (alpha <= 1 smooths, alpha > 1 sharpens)
%   beta: Edge scaling factor (beta < 1 compresses, beta > 1 expands dynamic range)

% 1. Initialize

out = zeros(size(I), 'like', I);
noise_level = 0.01;  % From original paper

% 2. Compute pixel-wise difference
diff = I - g;
abs_diff = abs(diff);

% 3. Smooth transition for alpha < 1 (Eq. 3 in paper)
if alpha < 1
    tau = smooth_step(noise_level, 2*noise_level, abs_diff*sigma_r);
else
    tau = 0;
end

% 4. Detail remapping (|i-g| ≤ sigma_r)
is_detail = abs_diff <= sigma_r;
d = abs_diff(is_detail) / sigma_r;  % Normalized detail [0,1]

% Apply f_d(d) = d^alpha with smooth transition
if alpha < 1
    fd = tau(is_detail).*(d.^alpha) + (1-tau(is_detail)).*d;
else
    fd = d.^alpha;
end
out(is_detail) = g + sign(diff(is_detail)).*sigma_r.*fd;



% 5. Edge remapping (|i-g| > sigma_r)
is_edge = ~is_detail;
a = abs_diff(is_edge) - sigma_r;  % Edge amplitude above threshold

%DEBUG
% fprintf('  Num detail pixels: %d, Num edge pixels: %d (Total: %d)\n', nnz(is_detail), nnz(is_edge), numel(I));
% if nnz(is_detail) > 0
%     fprintf('  Example detail diffs: %s\n', num2str(abs_diff(find(is_detail,3,'first'))'));
% end
% if nnz(is_edge) > 0
%     fprintf('  Example edge diffs: %s\n', num2str(abs_diff(find(is_edge,3,'first'))'));
% end

% Apply f_e(a) = beta*a (linear edge scaling)
fe = beta * a;
out(is_edge) = g + sign(diff(is_edge)).*(fe + sigma_r);

% 6. Clamp to valid range
out = max(0, min(1, out));
end

% Smooth step function (from original paper)
function y = smooth_step(xmin, xmax, x)
    y = (x - xmin)/(xmax - xmin);
    y = max(0, min(1, y));
    y = y.^2 .* (3 - 2*y); 
end