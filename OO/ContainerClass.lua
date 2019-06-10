-- --------------------------------------------------------------------------------------
-- ContainerClass.lua
-- UTHOR: Michael Peterson
-- ORIGINAL DATE: 28 December, 2018

local ADDON_C_NAME, MTP = ...
MTP.ContainerClass = {}	
Container = MTP.Container

local L = MTP.L
local E = errors
-- ************************************************************************************
--                      CONTAINER CLASS
-- ************************************************************************************
Container.__index = Container

setmetatable(Container, {
  __call = function (cls, ...)
    			local self = setmetatable({}, cls)
    			self:_init(...)
    			return self
  		    end,
})

function Container:_init()
  self.is_a = "ContainerObject"
  self.result = DEFAULT_RESULT
end

--                      Container methods
function Container:type()
    return self.is_a
end
function Container:getResult()
  return self.result
end
function Container:print()
  print( self.is_a )
end
