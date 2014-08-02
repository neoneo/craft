import craft.core.request.*;

component extends="mxunit.framework.TestCase" {

	public void function beforeTests() {
		variables.endPoint = new stubs.EndPointStub()
		variables.parser = new RoutesParser(new stubs.CommandFactoryStub())

		variables.parser.read(ExpandPath("/crafttests/integration/routes"))
	}

	public void function Root() {
		var result = testRequest("GET", "/")
		assertEquals({
			command: "Root",
			method: "GET",
			path: "/",
			extension: "html",
			parameters: null
		}, result)
	}

	public void function ArtistList() {
		var result = testRequest("GET", "/artists")
		assertEquals({
			command: "ArtistList",
			method: "GET",
			path: "/artists",
			extension: "html",
			parameters: null
		}, result)

		var result = testRequest("GET", "/artists.xml")
		assertEquals({
			command: "ArtistList",
			method: "GET",
			path: "/artists.xml",
			extension: "xml",
			parameters: null
		}, result)
	}

	private Struct function testRequest(required String method, required String path, Struct parameters) {

		variables.endPoint.setTestRequestMethod(arguments.method)
		variables.endPoint.setTestPath(arguments.path)

		var parameters = arguments.parameters ?: null
		if (parameters !== null) {
			variables.endPoint.setTestParameters(parameters)
		}

		var context = new Context(variables.endPoint, variables.parser.root())
		var pathSegment = context.pathSegment()
		var command = pathSegment.command(arguments.method)

		return command.execute(context)
	}

}