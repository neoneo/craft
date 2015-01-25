component extends="tests.MocktorySpec" {

	function run() {

		describe("Endpoint", function () {

			beforeEach(function () {
				endpoint = mock("Endpoint")
				endpoint.$("getContextRoot", "")
				endpoint.$property("contextRoot", "this", "")
			})

			describe(".requestParameters", function () {
				it("should return merged url and form scopes with form taking precedence", function () {
					// When merge url and form is enabled in the administrator, this test is not useful.
					// We have to set the url variables first, so that the test doesn't fail in that case.
					url.a = 2
					url.x = 2
					url.y = "string 2"
					form.a = 1
					form.b = "string 1"

					var parameters = endpoint.requestParameters
					var merged = {a: 1, b: "string 1", x: 2, y: "string 2"}

					// The form contains fields introduced by Railo.
					for (var key in merged) {
						expect(parameters).toHaveKey(key)
						expect(parameters[key]).toBe(merged[key])
					}
				})
			})

			describe(".extension", function () {

				it("should return the file extension if it is supported", function () {
					expect(endpoint.extension("/path/to/request.html")).toBe("html")
					expect(endpoint.extension("/path/to/request.json")).toBe("json")
					expect(endpoint.extension("/path/to/request.pdf")).toBe("pdf")
					expect(endpoint.extension("/path/to/request.txt")).toBe("txt")
					expect(endpoint.extension("/path/to/request.xml")).toBe("xml")
				})

				it("should return the empty string if there is no extension or it is not supported", function () {
					expect(endpoint.extension("/path/to/request")).toBe("")
					expect(endpoint.extension("/path/to/request.notexist")).toBe("")
				})

			})

			describe(".contentType", function () {

				it("should return the content type if it is recognized", function () {
					expect(endpoint.contentType("html")).toBe("text/html")
					expect(endpoint.contentType("json")).toBe("application/json")
					expect(endpoint.contentType("pdf")).toBe("application/pdf")
					expect(endpoint.contentType("txt")).toBe("text/plain")
					expect(endpoint.contentType("xml")).toBe("application/xml")
				})

				it("should return the html content type if the content type is not recognized", function () {
					expect(endpoint.contentType("")).toBe("text/html")
					expect(endpoint.contentType("content/unknown")).toBe("text/html")
				})

			})

			describe(".createURL", function () {

				it("should serialize request parameters in the query string", function () {
					var result = endpoint.createURL("/request.html", {a: 1, b: 2});
					// We don't know the order of the parameters. Split the result into an array.
					var parts = result.listToArray("?&")
					expect(result).toMatch("[?&]a=1")
					expect(result).toMatch("[?&]b=2")
				})

			})

			describe(".createURL without context root and index file", function () {

				beforeEach(function () {
					endpoint.$("getPath", "/test/test")
				})

				it("absolute path", function () {
					var result = endpoint.createURL("/request.html")
					expect(result).toBe("/request.html")
				})

				it("relative path starting with './'", function () {
					var result = endpoint.createURL("./request.html")
					expect(result).toBe("/test/test/request.html")
				})

				it("relative path starting with '../'", function () {
					var result = endpoint.createURL("../request.html")
					expect(result).toBe("/test/request.html")
				})

				it("relative path starting with '../../'", function () {
					var result = endpoint.createURL("../../request.html")
					expect(result).toBe("/request.html")
				})

				it("path with a './' in the middle", function () {
					var result = endpoint.createURL("/request/one/./two.html")
					expect(result).toBe("/request/one/two.html")
				})

				it("path with a '../' in the middle", function () {
					var result = endpoint.createURL("/request/one/../two.html")
					expect(result).toBe("/request/two.html")
				})

				it("relative path using '../' and './' at various locations", function () {
					var result = endpoint.createURL("../../request/./one/two/../three.html")
					expect(result).toBe("/request/one/three.html")
				})

			})

			describe(".createURL without context root, with index file", function () {

				beforeEach(function () {
					endpoint.indexFile = "/index.cfm"
					endpoint.$("getPath", "/test/test")
				})

				it("absolute path", function () {
					var result = endpoint.createURL("/request.html")
					expect(result).toBe("/index.cfm/request.html")
				})

				it("relative path starting with './'", function () {
					var result = endpoint.createURL("./request.html")
					expect(result).toBe("/index.cfm/test/test/request.html")
				})

				it("relative path starting with '../'", function () {
					var result = endpoint.createURL("../request.html")
					expect(result).toBe("/index.cfm/test/request.html")
				})

			})

			describe(".createURL with context root, with or without index file", function () {

				beforeEach(function () {
					endpoint.$("getContextRoot", "/context")
					endpoint.$property("contextRoot", "this", "/context")
					endpoint.$("getPath", "/test/test")
				})

				describe("without index file", function () {

					it("absolute path", function () {
						var result = endpoint.createURL("/request.html")
						expect(result).toBe("/context/request.html")
					})

					it("relative path starting with './'", function () {
						var result = endpoint.createURL("./request.html")
						expect(result).toBe("/context/test/test/request.html")
					})

					it("relative path starting with '../'", function () {
						var result = endpoint.createURL("../request.html")
						expect(result).toBe("/context/test/request.html")
					})

				})

				describe("with index file", function () {

					beforeEach(function () {
						endpoint.indexFile = "/index.cfm"
						endpoint.$("getPath", "/test/test")
					})

					it("absolute path", function () {
						var result = endpoint.createURL("/request.html")
						expect(result).toBe("/context/index.cfm/request.html")
					})

					it("relative path starting with './'", function () {
						var result = endpoint.createURL("./request.html")
						expect(result).toBe("/context/index.cfm/test/test/request.html")
					})

					it("relative path starting with '../'", function () {
						var result = endpoint.createURL("../request.html")
						expect(result).toBe("/context/index.cfm/test/request.html")
					})

				})

			})

		})

	}

}