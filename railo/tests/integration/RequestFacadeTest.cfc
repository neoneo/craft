import craft.request.*;

component extends="mxunit.framework.TestCase" {

	public void function beforeTests() {
		variables.facade = new stubs.RequestFacadeStub(new stubs.CommandFactoryStub())
		variables.endPoint = variables.facade.endPoint()

		variables.facade.importRoutes("/crafttests/integration/test.routes")
	}

	public void function ArtistList() {
		var result = testRequest("GET", "/artists.json")
		assertEquals({
			command: "ArtistList",
			method: "GET",
			path: "/artists.json",
			extension: "json",
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

		savecontent variable="local.output" {
			variables.facade.handleRequest()
		}

		return DeserializeJSON(output)
	}

}