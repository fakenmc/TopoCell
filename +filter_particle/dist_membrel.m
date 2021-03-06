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

function rating = dist_membrel(dataIn, toFilterIndexes, params)

distMemb = cell2mat({dataIn.particles(toFilterIndexes).dist_geoCP_memb});
distCC = cell2mat({dataIn.particles(toFilterIndexes).dist_geoCP_geoCC});

% If requested, consider particle volume
if params.specificParams.useVol == 1
    % Get particles radius
    pRadius = filter_particle.common.getradius( ...
        cell2mat({dataIn.particles(toFilterIndexes).vol})', ...
        params.dims ...
    );
    % Ajust distances
    distMemb = distMemb - pRadius;
    distCC = distCC - pRadius;
end;


rating = (distCC ./ (distMemb + distCC))';

