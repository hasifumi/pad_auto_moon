module ..., package.seeall
export *

call = ->
	print "module"

class TestClass
	new: (@name) =>
	greet: => print "My name is ", @name

-- test_class = TestClass "rio"
-- test_class\greet!

