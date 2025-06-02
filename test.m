g_val = 0.5;
i_vals = linspace(0, 1, 500);
remapped_vals = arrayfun(@(i) remapping_function(i, g_val, 0.01, 8, 5), i_vals);

figure;
plot(i_vals, remapped_vals, 'b', 'LineWidth', 2);
hold on;
plot(i_vals, i_vals, 'k--');  % Identity line
xlabel('Input intensity i');
ylabel('Remapped value');

grid on;
legend('Remapped', 'Identity');


I = repmat(linspace(0, 1, 256), 256, 1);  % synthetic horizontal ramp
g = I;  % guide is the same
s = 0.01; alpha = 8; beta = 5;

out = remapping_function(single(I), single(g), s, alpha, beta);
imshowpair(I, out, 'montage');
title('Original vs Remapped with alpha=5, s=0.2');
