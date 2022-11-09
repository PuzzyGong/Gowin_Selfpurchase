 
function result = isOctave()
    result = exist('OCTAVE_VERSION') ~= 0;
end