import craft.request.Context;

component extends="tests.MocktorySpec" {

	function run() {

		describe("Context", function () {

			beforeEach(function () {
				endpoint = mock({
					$class: "Endpoint",
					path: "/",
					extension: "extension",
					contentType: "content type",
					requestMethod: "request method",
					requestParameters: {a: 1}
				})
				root = mock("PathSegment")

				context = new Context(endpoint, root)
			})

			describe(".createURL", function () {
				it("should create the url", function () {
					mock({
						$object: endpoint,
						createURL: {
							$args: ["/test"],
							$returns: "/test1/test2",
							$times: 1
						}
					})

					context.endpoint = endpoint
					expect(context.createURL("/test")).toBe("/test1/test2")
					verify(endpoint)
				})
			})

			it("should get the extension from the endpoint", function () {
				expect(context.extension).toBe("extension")
			})

			it("should get the content typefrom the endpoint", function () {
				expect(context.contentType).toBe("content type")
			})

			it("should get the request method from the endpoint", function () {
				expect(context.requestMethod).toBe("request method")
			})

			it("should get the request parameters from the endpoint", function () {
				expect(context.parameters).toBe({a: 1})
			})

		})

	}

}