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
	self.baseClass = "" 																		-- base class (if class)
	self.attributes = {} 																		-- attribute hash (l/c name => text)
	self.methods = {} 																			-- methods defined (if class)
	self.comment = "" 																			-- main comment string 
end

--//	Add a comment line (e.g. one that is prefixed with the -- // sequence) to a documentation store 
--//  	@line [string]	the line to add (should still have --// prefix)

function DocStore:addLine(line)
	assert(line:sub(1,4) == "--//")																-- check it does indeed still have --// on the front.
	line = self:strip(line:sub(5)) 																-- remove spaces
	local key,comment = line:match("^%@(%w+)%s+(.*)$") 											-- look for @x xxxxx pattern
	if key ~= nil then 																			-- parameter provided (e.g. @something)
		key = key:lower() 																		-- case insensitive.
		assert(self.attributes[key] == nil,"Duplicate attribute "..key)							-- not already defined.
		self.attributes[key] = self:strip(comment)												-- assign the data to it.
	else 
		self.comment = self.comment .. " " .. line 												-- add line to main comment
		self.comment = self:strip(self.comment):gsub("  "," ") 									-- remove leading/trailing spaces and double spaces
	end
end

--//	Remove leading and trailing spaces from a line, and convert tabs to spaces.
--//	@line 	[string] 	line to strip of spaces
--//	@return [string]	stripped line

function DocStore:strip(line)
	line = line:gsub("\t"," ") 																	-- tabs to spaces.
	line = line:match("^%s*(.*)$") 																-- strip leading spaces.
	while line:match("%s$") do line = line:sub(1,-2) end 										-- strip trailing spaces.
	return line
end

--- ************************************************************************************************************************************************************************
--//							This class processes a file, scanning for the inline document text and class and method signatures
--- ************************************************************************************************************************************************************************

local SourceProcessor = Base:new()

--//	Constructor

function SourceProcessor:initialise()
	self.current = DocStore:new() 																-- current commented being collected.
	self.classes = {} 																			-- classes collected (class name => DocStore object)
end

--//	Scan a source file for inline comments, classes and methods and store them appropriately.
--//	@sourceFile [string]	File to scan.

function SourceProcessor:process(sourceFile)
	print("Now parsing "..sourceFile)
	local h = io.open(sourceFile,"r")															-- open source file
	assert(h ~= nil,"Could not open file " .. sourceFile)
	for line in h:lines() do 																	-- scan through the file
		if line:sub(1,4) == "--//" then 														-- inline comment data
			self.current:addLine(line)															-- add it to the inline comment store
		else 												
			local p = line:find("%-%-")															-- remove comments if any. Hopefully [[ ]] comments shouldn't matter.
			if p ~= nil then line = line:sub(1,p) end
			local newClass,baseClass = line:match("([A-Z]%w*)%s=%s(%w+)%:new%(%)") 				-- detect a class definition this is checks for newClass = baseClass:new()
																								-- but newClass must be capitalised in class definitions.
			if newClass ~= nil then 															-- found such a class.
				assert(self.classes[newClass] == nil,"Class duplicated "..newClass)				-- check it doesn't already exist (consequences for local classes)
				self.current.name = newClass 													-- update member variables in current saved class - saves lots of accessors :)
				self.current.baseClass = baseClass 										
				self.classes[newClass] = self.current 											-- make the current document store the info for this class.
				self.current = DocStore:new() 													-- and we have a new document store.
				print("    Found class " .. newClass)
				-- print("*",newClass,baseClass,line,self.classes[newClass].comment)
			end 
								
			local class,method,parameters =														-- detect a function definition <class>:<method>(<parameters>), again class capitalised. 
									line:match("function%s+([A-Z]%w*)%:(%w+)%(([%w%,]*)%)")		-- this is very specific to my coding style :)

			if class ~= nil then 																-- found a method definition.
				assert(self.classes[class] ~= nil,"Class unknown in method def "..line) 		-- the class must have been defined already.
				local thisClass = self.classes[class] 											-- keep a reference to it.
				assert(thisClass.methods[method] == nil,"Duplicate method "..line)				-- check the method doesn't already exist.
				thisClass.methods[method] = self.current 										-- save doc store in methods table for the class.
				self.current.name = method 														-- name is method - this is kept in the methods table of the class
				self.current.parameters = parameters 											-- save the parameter list
				self.current = DocStore:new() 													-- a new document store
				print("        Found method "..class..":"..method)
				-- print(">",class,method,parameters,thisClass.methods[method].comment)
			end
		end
	end
	h:close() 																					-- and completed.
	print("Parsing complete.")
end


local sp = SourceProcessor:new()
sp:process("luadoc.lua")