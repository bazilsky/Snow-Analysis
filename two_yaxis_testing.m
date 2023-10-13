% Assuming x, y1, y2, and y3 are your data vectors
x = linspace(0, 10, 100);
y1 = sin(x);
y2 = 100*cos(x);
y3 = 1000*tan(x);

% Create a figure
figure;

% Plot y1 using the left y-axis
yyaxis left;
plot(x, y1, 'b-');
ylabel('Sine values');

% Create new axes for the first right y-axis
ax1 = axes('Position', get(gca, 'Position'), 'YAxisLocation', 'right', ...
    'Color', 'none', 'XColor', 'none');

% Plot y2 using the first right y-axis
line(x, y2, 'Parent', ax1, 'Color', 'r');
ylabel(ax1, '100 times Cosine values', 'Color', 'r');
set(ax1, 'YColor', 'r');

% Create new axes for the second right y-axis
ax2 = axes('Position', get(ax1, 'Position') + [0.05 0 0 0], 'YAxisLocation', 'right', 'Color', 'none', 'XColor', 'none');


% Plot y3 using the second right y-axis
line(x, y3, 'Parent', ax2, 'Color', 'm');
ylabel(ax2, '1000 times Tangent values', 'Color', 'm');
set(ax2, 'YColor', 'm');

% Label the x-axis
xlabel('x values');

% Optionally, add a title
title('Example of a plot with three y-axes');
