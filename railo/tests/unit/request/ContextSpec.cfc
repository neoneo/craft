import craft.request.*;

component extends="tests.MocktorySpec" {

	function beforeAll() {

		super.beforeAll()

		// Create a path structure that contains segments using all types of path matchers
		// FIXME: We're using real objects where mocks should be used.
		root = new RootPathSegment()
		index = new StaticPathSegment("index")
		test1 = new StaticPathSegment("test1", "first")
		test2 = new StaticPathSegment("test2", "second")
		test3 = new StaticPathSegment("test3", "third")
		entire = new EntirePathSegment("entire")

		mock({
			$object: root,
			children: [
				{
					$object: index
				},
				{
					$object: test1,
					children: [
						{
							$object: test2,
							children: [
								{
									$object: test3,
								}
							]
						}
					]
				},
				{
					$object: entire
				}
			]
		})

	}

	function run() {

		describe("Context", function () {

			beforeEach(function () {
				endpoint = mock("Endpoint")

				context = CreateObject("Context") // Don't use new, since there is much logic in the constructor that we want to test.
			})

			describe(".init", function () {

				beforeEach(function () {
					mock({
						$object: endpoint,
						// The context always asks the endpoint for the extension.
						extension: {
							$returns: "html",
							$times: 1
						},
						contentType: {
							$returns: "text/html",
							$times: 1
						},
						requestMethod: {
							$returns: "get",
							$times: 1
						}
					})
				})

				it("should get the extension, the content type and the request method from the endpoint", function () {
					endpoint.$("getPath", "/")
					context.init(endpoint, root)
					verify(endpoint)
				})

				it("should set the matching path segment when the path has no extension", function () {
					endpoint.$("getPath", "/index")
					context.init(endpoint, root)
					$assert.isSameInstance(index, context.pathSegment)
				})

				it("should set the matching path segment when the path has an extension", function () {
					endpoint.$("getPath", "/index.html")
					context.init(endpoint, root)
					$assert.isSameInstance(index, context.pathSegment)
				})

				it("should set the matching path segment when the path has another extension", function () {
					endpoint.$("getPath", "/index.json")
					context.init(endpoint, root)
					$assert.isSameInstance(index, context.pathSegment)
				})

				it("should set the matching path segment when the path has no extension and ends with a slash", function () {
					endpoint.$("getPath", "/index/")
					context.init(endpoint, root)
					$assert.isSameInstance(index, context.pathSegment)
				})

				it("should set the matching path segment when the path has an extension and ends with a slash", function () {
					endpoint.$("getPath", "/index.html/")
					context.init(endpoint, root)
					$assert.isSameInstance(index, context.pathSegment)
				})

				it("should set the root path segment if the path is one single slash", function () {
					endpoint.$("getPath", "/")
					context.init(endpoint, root)
					$assert.isSameInstance(root, context.pathSegment)
				})

				it("should set the matching path segment and set the request parameter to the matched segment", function () {
					endpoint.$("getPath", "/test1")
					context.init(endpoint, root)
					$assert.isSameInstance(test1, context.pathSegment)
					var parameters = context.parameters
					expect(parameters).toHaveKey("first")
					expect(parameters.first).toBe("test1")
				})

				it("should set the matching child path segment and set request parameters for the matching segments", function () {
					endpoint.$("getPath", "/test1/test2")
					context.init(endpoint, root)
					$assert.isSameInstance(test2, context.pathSegment)
					var parameters = context.parameters
					expect(parameters).toHaveKey("first")
					expect(parameters.first).toBe("test1")
					expect(parameters).toHaveKey("second")
					expect(parameters.second).toBe("test2")
				})

				it("should set the matching grandchild path segment and set request parameters for the matching segments", function () {
					endpoint.$("getPath", "/test1/test2/test3")
					context.init(endpoint, root)
					$assert.isSameInstance(test3, context.pathSegment)
					var parameters = context.parameters
					expect(parameters).toHaveKey("first")
					expect(parameters.first).toBe("test1")
					expect(parameters).toHaveKey("second")
					expect(parameters.second).toBe("test2")
					expect(parameters).toHaveKey("third")
					expect(parameters.third).toBe("test3")
				})

				it("should continue matching when the path was matched partially", function () {
					// the test4 segment is not mapped, so the search should revert to the entire path matcher
					endpoint.$("getPath", "/test1/test2/test3/test4")
					context.init(endpoint, root)
					$assert.isSameInstance(entire, context.pathSegment)
					var parameters = context.parameters
					expect(parameters).toHaveKey("entire")
					expect(parameters.entire).toBe("test1/test2/test3/test4")
				})

				it("should set the same path segment regardless of the number of slashes", function () {
					endpoint.$("getPath", "index")
					context.init(endpoint, root)
					$assert.isSameInstance(index, context.pathSegment)

					endpoint.$("getPath", "//index")
					context.init(endpoint, root)
					$assert.isSameInstance(index, context.pathSegment)

					endpoint.$("getPath", "///index")
					context.init(endpoint, root)
					$assert.isSameInstance(index, context.pathSegment)

					endpoint.$("getPath", "test1//test2")
					context.init(endpoint, root)
					$assert.isSameInstance(test2, context.pathSegment)

					endpoint.$("getPath", "//test1//test2//")
					context.init(endpoint, root)
					$assert.isSameInstance(test2, context.pathSegment)
				})

			})

			describe(".createURL", function () {
				it("should forward the call to endpoint.createURL", function () {
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

		})


	}

}