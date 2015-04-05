component extends="tests.MocktorySpec" {

	function run() {

		describe("Handling requests", function () {

			beforeEach(function () {
				commandFactory = mock({
					$interface: "CommandFactory",
					create: function (identifier) {
						var identifier = arguments.identifier
						return mock({
							$interface: "Command",
							execute: function (context) {
								return identifier;
							}
						});
					}
				})

				handler = mock({
					$class: "Handler",
					// First override createEndPoint().
					createEndPoint: mock("Endpoint")
				})
				// Then call the constructor.
				handler.init(commandFactory)
			})

			it("should be impl", function () {
			})

		})

	}


	// public void function beforeTests() {
	// 	this.facade = new stubs.RequestFacadeStub(new stubs.CommandFactoryStub())
	// 	this.endpoint = this.facade.endpoint

	// 	this.facade.importRoutes("/tests/integration/test.routes")
	// }

	// public void function tearDown() {
	// 	content type="text/html" reset="false";
	// }

	// public void function ArtistList() {
	// 	var result = testRequest("GET", "/artists.json")
	// 	assertEquals({
	// 		command: "ArtistList",
	// 		method: "GET",
	// 		path: "/artists.json",
	// 		extension: "json",
	// 		parameters: null
	// 	}, result)
	// }

	// private Struct function testRequest(required String method, required String path, Struct parameters) {

	// 	this.endpoint.setTestRequestMethod(arguments.method)
	// 	this.endpoint.setTestPath(arguments.path)

	// 	var parameters = arguments.parameters ?: null
	// 	if (parameters !== null) {
	// 		this.endpoint.setTestParameters(parameters)
	// 	}

	// 	savecontent variable="local.output" {
	// 		this.facade.handleRequest()
	// 	}

	// 	return DeserializeJSON(output)
	// }

}