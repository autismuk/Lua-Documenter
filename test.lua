
--// Class 1 Description

local Class1 = Base:new()

--// Class1 doSomething

function Class1:doSomethingClass1()

--// Class1 overridden

function Class1:overridden()

--//% Class 1 internal method

function Class1:whoCares()

--// Class2 description

local Class2 = Class1:new()

--// Class2 doSomething

function Class2:doSomethingClass2()

--// Class 2 Overridden

function Class2:overridden()

--// Class 3 description

local Class3 = Class2:new()

--// Class 3 method

function Class3:doSomethingClass3()