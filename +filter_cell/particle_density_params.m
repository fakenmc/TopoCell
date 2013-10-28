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

function params = particle_density_params(args)

result = textscan(args, '%s %f');

params = struct('particleType', result{1}, 'intensDep', result{2});

% Check if intensDep is 0 or 1
if ((params.intensDep ~= 0) && (params.intensDep ~= 1))
    error(['Error particle_density function parameters: intensDep parameter must be 0 or 1, "' params.intensDep '" given.']);
end;

end % function