import craft.request.PathSegmentFactory;

component extends="tests.MocktorySpec" {

	function run() {

		describe("PathSegmentFactory", function () {

			beforeEach(function () {
				factory = new PathSegmentFactory()
			})

			describe(".create", function () {

				it("should return a RootPathSegment if the path is '/'", function () {
					var pathSegment = factory.create("/")
					expect(pathSegment).toBeInstanceOf("RootPathSegment")
				})

				it("should return an EntirePathSegment if the path is '*'", function () {
					var pathSegment = factory.create("*", "par")
					expect(pathSegment).toBeInstanceOf("EntirePathSegment")
					expect(pathSegment.parameterName).toBe("par")
				})

				it("should return a DynamicPathSegment if the path contains regex characters", function () {
					var pathSegment = factory.create("[0-9]+", "par3")
					expect(pathSegment).toBeInstanceOf("DynamicPathSegment")
					expect(pathSegment.pattern).toBe("[0-9]+")
					expect(pathSegment.parameterName).toBe("par3")
				});

				it("should return a StaticPathSegment if the path is something else", function () {
					var pathSegment = factory.create("static", "par2")
					expect(pathSegment).toBeInstanceOf("StaticPathSegment")
					expect(pathSegment.pattern).toBe("static")
					expect(pathSegment.parameterName).toBe("par2")
				})

			})

		})

	}

}