function dBObject = dbobject( I )
%DBOBJECT MATLAB data structure to mongodb datastructure
%   Detailed explanation goes here

dBObject = com.mongodb.util.JSON.parse(I);

end

