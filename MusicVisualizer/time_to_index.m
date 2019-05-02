% Copyright 2016 - 2016 The MathWorks, Inc.
function idx = time_to_index(timeelapsed, timestep)
idx = round((timeelapsed + timestep/2)/timestep);
end