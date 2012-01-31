% Helper function for determining and performing
% comparisons between two values.

function result = comparison(type, value1, value2)

if (strcmp(type, 'gt'))
    result = value1 > value2;
elseif (strcmp(type, 'lt'))
    result = value1 < value2;
end;
