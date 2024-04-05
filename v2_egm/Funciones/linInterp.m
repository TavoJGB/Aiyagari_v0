function zinterp = linInterp(x,y,z,extrap)

[lower,upper,weight] = getWeights(x,y);

if strcmp(extrap,'cap')
    % no extrapolation
    weight(weight>1) = 1;
    weight(weight<0) = 0;
end

% interpolation
zinterp = z(lower).*weight + z(upper).*(1-weight);