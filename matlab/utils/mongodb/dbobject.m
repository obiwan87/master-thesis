function dBObject = dbobject( I )
%DBOBJECT MATLAB data structure to mongodb datastructure
%   Detailed explanation goes here

import com.mongodb.*
import com.mongodb.util.*

dBObject = com.mongodb.util.JSON.parse(I);

end

