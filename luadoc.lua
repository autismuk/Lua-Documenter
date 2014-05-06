--- ************************************************************************************************************************************************************************
---
---				Name : 		luadoc.lua
---				Purpose :	Script providing simple inline documentation features for my personal coding style.
---				Created:	6 May 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	MIT
---
--- ************************************************************************************************************************************************************************

-- Standard OOP (with Constructor parameters added.)
_G.Base =  _G.Base or { new = function(s,...) local o = { } setmetatable(o,s) s.__index = s o:initialise(...) return o end, initialise = function() end }

--- ************************************************************************************************************************************************************************
--//	This is the main storage class which holds a 'chunk' of comments and attributes, it is general purpose because at the time of creation
--//	we don't know whether it refers to a class or a method.
--- ************************************************************************************************************************************************************************

local DocStore = Base:new()

--//	Creates an empty storage element

function DocStore:initialise()
	self.name = "" 																				-- name of class or method
	self.parameters = "" 																		-- parameter list (if method)
	self.attributes = {} 																		-- attribute hash (l/c name => text)
	self.comment = "" 																			-- main comment string 
end
