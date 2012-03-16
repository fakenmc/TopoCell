function radius = getradius(pVol, dims)
%GETRADIUS Get radius of particles
%   pVol - particle volumes
%   dims - dimension used (2d or 3d)

% Determine particle radius, depending if dimensions are 2D or 3D
if dims == 2
    radius = sqrt(pVol / pi); % radius taken from area of a circle
elseif dims == 3
    radius = power(3 * pVol / (4 * pi), 1/3); % radius taken from volume of a sphere
else
    error('Dimensions must be 2D or 3D.');
end;

end % function

