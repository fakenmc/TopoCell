%
% This file is part of TopoCell.
% 
% TopoCell is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by 
% the Free Software Foundation, either version 3 of the License, or 
% (at your option) any later version.
% 
% TopoCell is distributed in the hope that it will be useful, 
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License 
% along with TopoCell. If not, see <http://www.gnu.org/licenses/>.
%

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

