function [lower,upper,weight] = getWeights(x,y)

% The function returns three vectors:
% - lower: position in y of the nearest element below each x.
% - upper: position in y of the nearest element above each x.
% - weight: weight of lower in the linear combination that gives x.

% Finding elements in y immediately above and below x
    % Number of elements in each vector:
        sizX = length(x);
        sizY = length(y);
    % Find lower elements for each of them
        [~,~,lower] = histcounts(x,y);
        % Elements beyond the boundaries of y
        lower(x>y(end)) = sizY-1;
        lower(x<y(1)) = 1;
    % Corresponding upper neighbour
        upper = lower+1;
    % Computing the weight of the element below
        weight = (y(upper) - x) ./ (y(upper) - y(lower));
        % the weight for the upper element is (1 - weight)