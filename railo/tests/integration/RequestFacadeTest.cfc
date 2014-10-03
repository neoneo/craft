import craft.request.*;

component extends="mxunit.framework.TestCase" {

	public void function beforeTests() {
		this.facade = new stubs.RequestFacadeStub(new stubs.CommandFactoryStub())
		this.endPoint = this.facade.endPoint

		this.facade.importRoutes("/crafttests/integration/test.routes")
	}

	public void function tearDown() {
		content type="text/html" reset="false";
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

		this.endPoint.setTestRequestMethod(arguments.method)
		this.endPoint.setTestPath(arguments.path)

		var parameters = arguments.parameters ?: null
		if (parameters !== null) {
			this.endPoint.setTestParameters(parameters)
		}

		savecontent variable="local.output" {
			this.facade.handleRequest()
		}

		return DeserializeJSON(output)
	}

}