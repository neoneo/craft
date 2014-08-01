import craft.core.request.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		variables.parser = new RoutesParserStub(new CommandFactoryStub())
	}

	public void function RootRoute() {
		var route = "GET / root"
		var pathSegment = variables.parser.parse(route)

		assertSame(variables.parser.root(), pathSegment)
		// There should be a command for the GET method.
		var command = pathSegment.command("GET")
		// The command identifier should be 'root'.
		assertEquals("root", command.getIdentifier())
	}

	public void function OneLevelRoute() {
		var route = "GET /level1 level1command"
		var pathSegment = variables.parser.parse(route)

		assertEquals("level1", pathSegment.pattern())

		var command = pathSegment.command("GET")
		assertEquals("level1command", command.getIdentifier())
		// The parent should be the root. Get it from the parser stub, that has the root() method added for this purpose.
		assertSame(variables.parser.root(), pathSegment.parent())
	}

	public void function TwoLevelRoute() {
		var route = "GET /level1/level2 level2command"
		var pathSegment = variables.parser.parse(route)

		assertEquals("level2", pathSegment.pattern())

		var command = pathSegment.command("GET")
		assertEquals("level2command", command.getIdentifier())

		// Intermediate path segments should have been created.
		var parent = pathSegment.parent()
		assertEquals("level1", parent.pattern())

		var root = parent.parent()
		assertSame(variables.parser.root(), root)

		// Now add a route to the intermediate path segment:
		var route2 = "GET /level1 level1command"
		var pathSegment2 = variables.parser.parse(route2)
		// This segment should be the parent of the level2 path segment.
		assertSame(parent, pathSegment2)
		var command2 = pathSegment2.command("GET")
		assertEquals("level1command", command2.getIdentifier())
	}

	public void function TwoMethodsSameRoute() {
		var route1 = "GET / getcommand"
		var route2 = "POST / postcommand"

		var pathSegment1 = variables.parser.parse(route1)
		var pathSegment2 = variables.parser.parse(route2)

		// We should have the exact same instance twice.
		assertSame(pathSegment1, pathSegment2)

		var command1 = pathSegment1.command("GET")
		assertEquals("getcommand", command1.getIdentifier())
		var command2 = pathSegment1.command("POST")
		assertEquals("postcommand", command2.getIdentifier())
	}

	public void function MultipleWhitespace() {
		var route = "#Chr(9)#GET#Chr(9)#/       root   "
		var pathSegment = variables.parser.parse(route)

		assertSame(variables.parser.root(), pathSegment)
		var command = pathSegment.command("GET")
		assertEquals("root", command.getIdentifier())
	}

	public void function DotRoute() {
		var dotRoute = "GET . get"
		// Parsing this right away should throw an exception.
		try {
			var pathSegment = variables.parser.parse(dotRoute)
			fail("exception should have been thrown")
		} catch (NoSuchElementException e) {}

		// First parsing a route and then the dot route should work.
		var route = "POST / post" // Use a differen method, so we get two commands.
		var pathSegment = variables.parser.parse(route)

		var dotPathSegment = variables.parser.parse(dotRoute)

		assertSame(pathSegment, dotPathSegment)

		var command = pathSegment.command("POST")
		assertEquals("post", command.getIdentifier())
		var dotCommand = pathSegment.command("GET")
		assertEquals("get", dotCommand.getIdentifier())

		// If another dot route follows, this shouldn't be a problem.
		var dotRoute2 = "PUT . put"
		var dotPathSegment2 = variables.parser.parse(dotRoute2)
		assertSame(dotPathSegment, dotPathSegment2)
		var dotCommand2 = pathSegment.command("PUT")
		assertEquals("put", dotCommand2.getIdentifier())

	}

	public void function OneIndentRoute() {
		var route = "GET / root"
		// Parse this, so that the next call can use the indent.
		var pathSegment = variables.parser.parse(route)

		var indent1 = "GET > /indent1 indent1"
		var indent2 = "GET > /indent2 indent2"

		var pathSegment1 = variables.parser.parse(indent1)
		var pathSegment2 = variables.parser.parse(indent2)

		// Since it's relative to the root, the presence of the indent should not matter.
		assertSame(pathSegment, pathSegment1.parent())
		var command1 = pathSegment1.command("GET")
		assertEquals("indent1", command1.getIdentifier())
		assertSame(pathSegment, pathSegment2.parent())
		var command2 = pathSegment2.command("GET")
		assertEquals("indent2", command2.getIdentifier())
	}

	public void function MultipleIndentDedentRoute() {
		// Test this relative to some other path than the root.
		var route = "GET /index index"
		var pathSegment = variables.parser.parse(route)

		var indent1 = "GET > /indent1 indent1" // /index/indent1
		var pathSegment1 = variables.parser.parse(indent1)

		var indent2 = "GET >> /indent2 indent2" // /index/indent1/indent2
		var pathSegment2 = variables.parser.parse(indent2)

		var indent3 = "GET >>> /indent3 indent3" // /index/indent1/indent2/indent3
		var pathSegment3 = variables.parser.parse(indent3)

		assertSame(pathSegment, pathSegment1.parent())
		var command1 = pathSegment1.command("GET")
		assertEquals("indent1", command1.getIdentifier())

		assertSame(pathSegment1, pathSegment2.parent())
		var command2 = pathSegment2.command("GET")
		assertEquals("indent2", command2.getIdentifier())

		assertSame(pathSegment2, pathSegment3.parent())
		var command3 = pathSegment3.command("GET")
		assertEquals("indent3", command3.getIdentifier())

		// Dedent:
		var dedent4 = "GET > /dedent4 dedent4" // /index/dedent4
		var pathSegment4 = variables.parser.parse(dedent4)

		assertSame(pathSegment, pathSegment4.parent())
		var command4 = pathSegment4.command("GET")
		assertEquals("dedent4", command4.getIdentifier())

		// Now indent again (should be relative to the previous route):
		var indent5 = "GET >> /indent5 indent5" // /index/dedent4/indent5
		var pathSegment5 = variables.parser.parse(indent5)

		assertSame(pathSegment4, pathSegment5.parent())
		var command5 = pathSegment5.command("GET")
		assertEquals("indent5", command5.getIdentifier())

		// Same path:
		var dot6 = "POST . dot6" // /index/dedent4/indent5
		var pathSegment6 = variables.parser.parse(dot6)

		assertSame(pathSegment5, pathSegment6)
		var command6 = pathSegment6.command("POST")
		assertEquals("dot6", command6.getIdentifier())
	}

	public void function WrongIndent() {
		var route1 = "GET > /route1 route1"
		try {
			var pathSegment1 = variables.parser.parse(route1)
			fail("exception should have been thrown")
		} catch (NoSuchElementException e) {}

		// For the next test, parse a proper route first.
		var route = "GET / root"
		var pathSegment = variables.parser.parse(route)
		// Now indent too far:
		var route2 = "GET >> /route2 route2"
		try {
			var pathSegment2 = variables.parser.parse(route2)
			fail("exception should have been thrown")
		} catch (NoSuchElementException e) {}
	}

	public void function RouteWithoutSlash() {
		var route = "GET index index"
		var pathSegment = variables.parser.parse(route)

		// The route should be equal to /index.
		assertSame(variables.parser.root(), pathSegment.parent())
		var command = pathSegment.command("GET")
		assertEquals("index", command.getIdentifier())
	}

	public void function ParameterName() {
		var route1 = "GET /index@par1 index"
		var pathSegment1 = variables.parser.parse(route1)

		assertEquals("index", pathSegment1.pattern())
		assertEquals("par1", pathSegment1.parameterName())
		var command1 = pathSegment1.command("GET")
		assertEquals("index", command1.getIdentifier())

		var route2 = "GET /index/route@par2 route"
		var pathSegment2 = variables.parser.parse(route2)

		assertSame(pathSegment1, pathSegment2.parent())
		assertEquals("route", pathSegment2.pattern())
		assertEquals("par2", pathSegment2.parameterName())
		var command2 = pathSegment2.command("GET")
		assertEquals("route", command2.getIdentifier())
	}

	public void function EscapedParameterName() {
		var route1 = "GET /index\@escaped@par index"
		var pathSegment1 = variables.parser.parse(route1)

		assertEquals("index@escaped", pathSegment1.pattern())
		assertEquals("par", pathSegment1.parameterName())

		var route2 = "GET /wrong@escaped@par index"
		try {
			var pathSegment2 = variables.parser.parse(route2)
			fail("exception should have been thrown")
		} catch (IllegalArgumentException e) {}
	}

	public void function NotEnoughWords() {
		var route = "GET /index"
		try {
			var pathSegment = variables.parser.parse(route)
			fail("exception should have been thrown")
		} catch (NoSuchElementException e) {}
	}

	public void function CreatePathSegment() {
		var root = variables.parser.createPathSegment("/")
		assertTrue(IsInstanceOf(root, "RootPathSegment"))

		var entire = variables.parser.createPathSegment("*", "par1")
		assertTrue(IsInstanceOf(entire, "EntirePathSegment"))
		assertEquals("par1", entire.parameterName())

		var static = variables.parser.createPathSegment("static", "par2")
		assertTrue(IsInstanceOf(static, "StaticPathSegment"))
		assertEquals("static", static.pattern())
		assertEquals("par2", static.parameterName())

		var dynamic = variables.parser.createPathSegment("[0-9]+", "par3")
		assertTrue(IsInstanceOf(dynamic, "DynamicPathSegment"))
		assertEquals("[0-9]+", dynamic.pattern())
		assertEquals("par3", dynamic.parameterName())
	}

	/*
		Te maken tests:
		- createPathSegment methode (publiek maken en kijken of juiste type terug komt)

	*/

}