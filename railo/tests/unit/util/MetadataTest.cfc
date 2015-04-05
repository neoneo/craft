import craft.util.Metadata;

component extends="testbox.system.BaseSpec" {

	function run() {

		describe("Metadata", function () {
			beforeEach(function () {
				meta = new Metadata()
			})

			describe(".methodExists for class without inheritance", function () {

				beforeEach(function () {
					metadata = GetComponentMetadata("classes.BaseClass")
				})

				describe("and explicit methods", function () {

					it("should return true if the method has a high enough access modifier", function () {
						// Public method:
						expect(meta.methodExists(metadata, "publicMethod", "public")).toBeTrue()
						// The method is public, so is also accessible if we have private or package access to the class.
						expect(meta.methodExists(metadata, "publicMethod", "package")).toBeTrue("if package access is required, a public method should be accessible")
						expect(meta.methodExists(metadata, "publicMethod", "private")).toBeTrue("if private access is required, a public method should be accessible")
						// Private method:
						expect(meta.methodExists(metadata, "privateMethod", "private")).toBeTrue()

					})

					it("should return false if the method does not have a high enough access modifier", function () {
						// Remote access is not allowed for the public method.
						expect(meta.methodExists(metadata, "publicMethod", "remote")).toBeFalse("if remote access is required, public access is not enough")

						// None of the other access levels would allow execution of the method.
						expect(meta.methodExists(metadata, "privateMethod", "package")).toBeFalse()
						expect(meta.methodExists(metadata, "privateMethod", "public")).toBeFalse()
						expect(meta.methodExists(metadata, "privateMethod", "remote")).toBeFalse()

					})

					it("should return false if the method does not exist", function () {
						// Test with private access requirement, because any method that exists would return true then.
						expect(meta.methodExists(metadata, "nonExistingMethod", "private")).toBeFalse()
					})

				})

				describe("and generated methods", function () {

					it("should return true if the property exists unless remote access is required", function () {
						expect(meta.methodExists(metadata, "getProperty1", "public")).toBeTrue()
						expect(meta.methodExists(metadata, "getProperty1", "package")).toBeTrue()
						expect(meta.methodExists(metadata, "getProperty1", "private")).toBeTrue()
						expect(meta.methodExists(metadata, "getProperty1", "remote")).toBeFalse()
					})

					it("should return false if the property exists but has no accessor", function () {
						// There is no setter for property2.
						expect(meta.methodExists(metadata, "setProperty2", "private")).toBeFalse()
					})

					it("should return false if the property does not exist", function () {
						expect(meta.methodExists(metadata, "setNonExistingProperty", "private")).toBeFalse()
					})

				})

			})

			describe(".methodExists for class with inheritance", function () {

				beforeEach(function () {
					metadata = GetComponentMetadata("classes.SubSubClass")
				})

				describe("and explicit methods", function () {

					// publicMethod is now private (due to SubClass)
					it("should return true if the method has a high enough access modifier", function () {
						expect(meta.methodExists(metadata, "publicMethod", "private")).toBeTrue()
						expect(meta.methodExists(metadata, "packageMethod", "private")).toBeTrue()
						expect(meta.methodExists(metadata, "packageMethod", "package")).toBeTrue()
						expect(meta.methodExists(metadata, "remoteMethod", "private")).toBeTrue()
						expect(meta.methodExists(metadata, "remoteMethod", "package")).toBeTrue()
						expect(meta.methodExists(metadata, "remoteMethod", "public")).toBeTrue()
						expect(meta.methodExists(metadata, "remoteMethod", "remote")).toBeTrue()

					})

					it("should return false if the method does not have a high enough access modifier", function () {
						expect(meta.methodExists(metadata, "publicMethod", "package")).toBeFalse()
						expect(meta.methodExists(metadata, "publicMethod", "public")).toBeFalse()
						expect(meta.methodExists(metadata, "publicMethod", "remote")).toBeFalse()
						expect(meta.methodExists(metadata, "packageMethod", "public")).toBeFalse()
						expect(meta.methodExists(metadata, "packageMethod", "remote")).toBeFalse()
					})

					it("should return false if the method does not exist", function () {
						expect(meta.methodExists(metadata, "nonExistingMethod", "private")).toBeFalse()
					})

				})

				describe("and generated methods", function () {

					it("should return true if the property exists unless remote access is required", function () {
						expect(meta.methodExists(metadata, "getProperty1", "public")).toBeTrue()
						expect(meta.methodExists(metadata, "getProperty1", "package")).toBeTrue()
						expect(meta.methodExists(metadata, "getProperty1", "private")).toBeTrue()
						expect(meta.methodExists(metadata, "getProperty1", "remote")).toBeFalse()

						// The setter for property2 should now exist.
						expect(meta.methodExists(metadata, "setProperty2", "private")).toBeTrue()
					})

				})

			})

			describe(".extends", function () {

				beforeEach(function () {
					metadata = GetComponentMetadata("classes.BaseClass")
					submetadata = GetComponentMetadata("classes.SubClass")
					subsubmetadata = GetComponentMetadata("classes.SubSubClass")
				})

				it("should return true if the given metadata belongs to a subclass", function () {
					expect(meta.extends(metadata, metadata.name)).toBeTrue()
					expect(meta.extends(submetadata, metadata.name)).toBeTrue()
					expect(meta.extends(subsubmetadata, metadata.name)).toBeTrue()
					expect(meta.extends(subsubmetadata, submetadata.name)).toBeTrue()
				})

				it("should return false if the given metadata does not belong to a subclass", function () {
					expect(meta.extends(metadata, submetadata.name)).toBeFalse()
					expect(meta.extends(metadata, subsubmetadata.name)).toBeFalse()
					expect(meta.extends(submetadata, subsubmetadata.name)).toBeFalse()
				})

			})

			describe(".collectProperties", function () {

				it("should return the property metadata defined in the class and its superclasses", function () {
					var metadata = GetComponentMetadata("classes.SubSubClass")
					var properties = meta.collectProperties(metadata)
						.sort(function (propertyA, propertyB) {
							return CompareNoCase(arguments.propertyA.name, arguments.propertyB.name);
						})

					expect(properties).toBe([
						{name: "property1", type: "String"},
						{name: "property2", type: "String", setter: "yes", default: "property"},
						{name: "property3", type: "String"},
						{name: "property4", type: "String"}
					])
				})

			})

			describe(".collectFunctions", function () {

				it("should return the function metadata defined in the class and its superclasses", function () {
					var metadata = GetComponentMetadata("classes.SubSubClass")
					var functions = meta.collectFunctions(metadata)
						.map(function (metadata) {
							// For this test we are only interested in the existence of the function with the proper access level.
							return {
								name: arguments.metadata.name,
								access: arguments.metadata.access
							};
						})
						.sort(function (functionA, functionB) {
							return CompareNoCase(arguments.functionA.name, arguments.functionB.name);
						})

					expect(functions).toBe([
						{name: "anotherPublicMethod", access: "public"},
						{name: "getProperty1", access: "public"},
						{name: "getProperty2", access: "public"},
						{name: "getProperty3", access: "public"},
						{name: "getproperty4", access: "public"},
						{name: "init", access: "private"},
						{name: "packageMethod", access: "package"},
						{name: "privateMethod", access: "private"},
						{name: "publicMethod", access: "private"},
						{name: "remoteMethod", access: "remote"},
						{name: "setProperty1", access: "public"},
						{name: "setProperty2", access: "public"},
						{name: "setProperty3", access: "public"},
						{name: "setProperty4", access: "public"}
					])
				})

			})

			describe(".scan", function () {
				it("should be implemented", function () {
					fail("TODO")
				})
			})

		})

	}

}