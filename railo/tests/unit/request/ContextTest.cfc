import craft.output.*;

import craft.request.*;

component extends="testbox.system.BaseSpec" {

	function beforeAll() {
		// Create a path structure that contains segments using all types of path matchers
		// FIXME: We're using real objects where mocks should be used.
		root = new RootPathSegment()
		index = new StaticPathSegment("index")
		test1 = new StaticPathSegment("test1", "first")
		test2 = new StaticPathSegment("test2", "second")
		test3 = new StaticPathSegment("test3", "third")
		entire = new EntirePathSegment("entire")

		mocktory = new tests.Mocktory($mockbox)
		mocktory.mock({
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
				endPoint = mocktory.mock({
					$object: CreateObject("EndPoint")
				})
			})

			describe(".parsePath", function () {

				it("should return the matching path segment when the path has no extension", function () {
					endPoint.$("getPath", "/index")
					var context = new Context(endPoint, root)
					$assert.isSameInstance(index, context.pathSegment)
				})

				it("should return the matching path segment when the path has an extension", function () {
					endPoint.$("getPath", "/index.html")
					var context = new Context(endPoint, root)
					$assert.isSameInstance(index, context.pathSegment)
				})

				it("should return the matching path segment when the path has another extension", function () {
					endPoint.$("getPath", "/index.json")
					var context = new Context(endPoint, root)
					$assert.isSameInstance(index, context.pathSegment)
				})

				it("should return the matching path segment when the path has no extension and ends with a slash", function () {
					endPoint.$("getPath", "/index/")
					var context = new Context(endPoint, root)
					$assert.isSameInstance(index, context.pathSegment)
				})

				it("should return the matching path segment when the path has an extension and ends with a slash", function () {
					endPoint.$("getPath", "/index.html/")
					var context = new Context(endPoint, root)
					$assert.isSameInstance(index, context.pathSegment)
				})

				it("should return the root path segment if the path is one single slash", function () {
					endPoint.$("getPath", "/")
					var context = new Context(endPoint, root)
					$assert.isSameInstance(root, context.pathSegment)
				})

				it("should return the matching path segment and set the request parameter to the matched segment", function () {
					endPoint.$("getPath", "/test1")
					var context = new Context(endPoint, root)
					$assert.isSameInstance(test1, context.pathSegment, "parsing /test1 should return the test1 path segment")
					var parameters = context.parameters
					expect(parameters).toHaveKey("first")
					expect(parameters.first).toBe("test1")
				})

				it("should return the matching child path segment and set request parameters for the matching segments", function () {
					endPoint.$("getPath", "/test1/test2")
					var context = new Context(endPoint, root)
					$assert.isSameInstance(test2, context.pathSegment, "parsing /test1/test2 should return the test2 path segment")
					var parameters = context.parameters
					expect(parameters).toHaveKey("first")
					expect(parameters.first).toBe("test1")
					expect(parameters).toHaveKey("second")
					expect(parameters.second).toBe("test2")
				})

				it("should return the matching grandchild path segment and set request parameters for the matching segments", function () {
					endPoint.$("getPath", "/test1/test2/test3")
					var context = new Context(endPoint, root)
					$assert.isSameInstance(test3, context.pathSegment, "parsing /test1/test2/test3 should return the test3 path segment")
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
					endPoint.$("getPath", "/test1/test2/test3/test4")
					var context = new Context(endPoint, root)
					$assert.isSameInstance(entire, context.pathSegment, "parsing /test1/test2/test3/test4 should return the entire path segment")
					var parameters = context.parameters
					expect(parameters).toHaveKey("entire")
					expect(parameters.entire).toBe("test1/test2/test3/test4")
				})

				it("should return the same path segment regardeless of the number of slashes", function () {
					endPoint.$("getPath", "index")
					var context = new Context(endPoint, root)
					$assert.isSameInstance(index, context.pathSegment)

					endPoint.$("getPath", "//index")
					var context = new Context(endPoint, root)
					$assert.isSameInstance(index, context.pathSegment)

					endPoint.$("getPath", "///index")
					var context = new Context(endPoint, root)
					$assert.isSameInstance(index, context.pathSegment)

					endPoint.$("getPath", "test1//test2")
					var context = new Context(endPoint, root)
					$assert.isSameInstance(test2, context.pathSegment)

					endPoint.$("getPath", "//test1//test2//")
					var context = new Context(endPoint, root)
					$assert.isSameInstance(test2, context.pathSegment)
				})

			})

		})

		describe(".createURL", function () {
			it("should forward the call to EndPoint.createURL", function () {
				// The context calls EndPoint.createURL using an argument collection, so the method signature of both methods should be the same.
				mocktory.mock({
					$object: endPoint,
					getPath: "/index.html",
					createURL: {
						$args: ["/test"],
						$returns: "",
						$times: 1
					}
				})
				var context = new Context(endPoint, root)

				context.createURL("/test")

				mocktory.verify(endPoint)
			})
		})

	}

}