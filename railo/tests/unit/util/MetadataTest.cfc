import craft.util.Metadata;

component extends="testbox.system.BaseSpec" {

	function beforeAll() {
		mapping = "/tests/unit/util/metadata"
		dotMapping = mapping.listChangeDelims(".", "/")
	}

	function run() {

		describe("Metadata", function () {
			beforeEach(function () {
				meta = new Metadata()
			})

			describe(".functionExists for class without inheritance", function () {

				beforeEach(function () {
					metadata = GetComponentMetadata(dotMapping & ".BaseClass")
				})

				describe("and explicit methods", function () {

					it("should return true if the method has a high enough access modifier", function () {
						// Public method:
						expect(meta.functionExists(metadata, "publicMethod", "public")).toBeTrue()
						// The method is public, so is also accessible if we have private or package access to the class.
						expect(meta.functionExists(metadata, "publicMethod", "package")).toBeTrue("if package access is required, a public method should be accessible")
						expect(meta.functionExists(metadata, "publicMethod", "private")).toBeTrue("if private access is required, a public method should be accessible")
						// Private method:
						expect(meta.functionExists(metadata, "privateMethod", "private")).toBeTrue()

					})

					it("should return false if the method does not have a high enough access modifier", function () {
						// Remote access is not allowed for the public method.
						expect(meta.functionExists(metadata, "publicMethod", "remote")).toBeFalse("if remote access is required, public access is not enough")

						// None of the other access levels would allow execution of the method.
						expect(meta.functionExists(metadata, "privateMethod", "package")).toBeFalse()
						expect(meta.functionExists(metadata, "privateMethod", "public")).toBeFalse()
						expect(meta.functionExists(metadata, "privateMethod", "remote")).toBeFalse()

					})

					it("should return false if the method does not exist", function () {
						// Test with private access requirement, because any method that exists would return true then.
						expect(meta.functionExists(metadata, "nonExistingMethod", "private")).toBeFalse()
					})

				})

				describe("and generated methods", function () {

					it("should return true if the property exists unless remote access is required", function () {
						expect(meta.functionExists(metadata, "getProperty1", "public")).toBeTrue()
						expect(meta.functionExists(metadata, "getProperty1", "package")).toBeTrue()
						expect(meta.functionExists(metadata, "getProperty1", "private")).toBeTrue()
						expect(meta.functionExists(metadata, "getProperty1", "remote")).toBeFalse()
					})

					it("should return false if the property exists but has no accessor", function () {
						// There is no setter for property2.
						expect(meta.functionExists(metadata, "setProperty2", "private")).toBeFalse()
					})

					it("should return false if the property does not exist", function () {
						expect(meta.functionExists(metadata, "setNonExistingProperty", "private")).toBeFalse()
					})

				})

			})

			describe(".functionExists for class with inheritance", function () {

				beforeEach(function () {
					metadata = GetComponentMetadata(dotMapping & ".SubSubClass")
				})

				describe("and explicit methods", function () {

					// publicMethod is now private (due to SubClass)
					it("should return true if the method has a high enough access modifier", function () {
						expect(meta.functionExists(metadata, "publicMethod", "private")).toBeTrue()
						expect(meta.functionExists(metadata, "packageMethod", "private")).toBeTrue()
						expect(meta.functionExists(metadata, "packageMethod", "package")).toBeTrue()
						expect(meta.functionExists(metadata, "remoteMethod", "private")).toBeTrue()
						expect(meta.functionExists(metadata, "remoteMethod", "package")).toBeTrue()
						expect(meta.functionExists(metadata, "remoteMethod", "public")).toBeTrue()
						expect(meta.functionExists(metadata, "remoteMethod", "remote")).toBeTrue()

					})

					it("should return false if the method does not have a high enough access modifier", function () {
						expect(meta.functionExists(metadata, "publicMethod", "package")).toBeFalse()
						expect(meta.functionExists(metadata, "publicMethod", "public")).toBeFalse()
						expect(meta.functionExists(metadata, "publicMethod", "remote")).toBeFalse()
						expect(meta.functionExists(metadata, "packageMethod", "public")).toBeFalse()
						expect(meta.functionExists(metadata, "packageMethod", "remote")).toBeFalse()
					})

					it("should return false if the method does not exist", function () {
						expect(meta.functionExists(metadata, "nonExistingMethod", "private")).toBeFalse()
					})

				})

				describe("and generated methods", function () {

					it("should return true if the property exists unless remote access is required", function () {
						expect(meta.functionExists(metadata, "getProperty1", "public")).toBeTrue()
						expect(meta.functionExists(metadata, "getProperty1", "package")).toBeTrue()
						expect(meta.functionExists(metadata, "getProperty1", "private")).toBeTrue()
						expect(meta.functionExists(metadata, "getProperty1", "remote")).toBeFalse()

						// The setter for property2 should now exist.
						expect(meta.functionExists(metadata, "setProperty2", "private")).toBeTrue()
					})

				})

			})

			describe(".extends", function () {

				beforeEach(function () {
					metadata = GetComponentMetadata(dotMapping & ".BaseClass")
					submetadata = GetComponentMetadata(dotMapping & ".SubClass")
					subsubmetadata = GetComponentMetadata(dotMapping & ".SubSubClass")
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
					var metadata = GetComponentMetadata(dotMapping & ".SubSubClass")
					var properties = meta.collectProperties(metadata)

					expect(properties).toBe({
						property1: {name: "property1", type: "String"},
						property2: {name: "property2", type: "String", setter: "yes", default: "property"},
						property3: {name: "property3", type: "String"},
						property4: {name: "property4", type: "String"}
					})
				})

			})

			describe(".collectFunctions", function () {

				it("should return the function metadata defined in the class and its superclasses", function () {
					var metadata = GetComponentMetadata(dotMapping & ".SubSubClass")
					var functions = meta.collectFunctions(metadata)
						.map(function (name, metadata) {
							// For this test we are only interested in the existence of the function with the proper access level.
							return {
								name: arguments.metadata.name,
								access: arguments.metadata.access
							};
						})

					expect(functions).toBe({
						anotherPublicMethod: {name: "anotherPublicMethod", access: "public"},
						getProperty1: {name: "getProperty1", access: "public"},
						getProperty2: {name: "getProperty2", access: "public"},
						getProperty3: {name: "getProperty3", access: "public"},
						getproperty4: {name: "getproperty4", access: "public"},
						init: {name: "init", access: "private"},
						packageMethod: {name: "packageMethod", access: "package"},
						privateMethod: {name: "privateMethod", access: "private"},
						publicMethod: {name: "publicMethod", access: "private"},
						remoteMethod: {name: "remoteMethod", access: "remote"},
						setProperty1: {name: "setProperty1", access: "public"},
						setProperty2: {name: "setProperty2", access: "public"},
						setProperty3: {name: "setProperty3", access: "public"},
						setProperty4: {name: "setProperty4", access: "public"}
					})
				})

			})

			describe(".list", function () {

				it("should return the metadata of all classes in the mapping", function () {
					var results = meta.list(mapping, false).map(function (metadata) {
						return arguments.metadata.name;
					}).sort("textnocase")
					expect(results).toBe([
						dotMapping & ".BaseClass",
						dotMapping & ".SubClass",
						dotMapping & ".SubSubClass"
					])
				})

				it("should ignore the metadata of interfaces", function () {
					var results = meta.list(mapping & "/interface", false)
					expect(results).toBeEmpty()
				})

				it("should return the metadata of all classes in the mapping recursively", function () {
					var results = meta.list(mapping, true).map(function (metadata) {
						return arguments.metadata.name;
					}).sort("textnocase")
					expect(results).toBe([
						dotMapping & ".BaseClass",
						dotMapping & ".package.Class",
						dotMapping & ".SubClass",
						dotMapping & ".SubSubClass"
					])
				})

			})

			describe(".annotation", function () {

				it("should return the value of the annotation", function () {
					var metadata = GetComponentMetadata(dotMapping & ".BaseClass")
					expect(meta.annotation(metadata, "base")).toBeTrue()
					expect(meta.annotation(metadata, "number")).toBe(1)
				})

				it("should return null if the annotation does not exist", function () {
					var metadata = GetComponentMetadata(dotMapping & ".BaseClass")
					expect(meta.annotation(metadata, "undefined")).toBeNull()
				})

				it("should return the value of the annotation if it is defined on a superclass", function () {
					var metadata = GetComponentMetadata(dotMapping & ".SubSubClass")
					expect(meta.annotation(metadata, "base")).toBeTrue()
					expect(meta.annotation(metadata, "sub")).toBeTrue()
					expect(meta.annotation(metadata, "number")).toBe(3)
				})

			})

		})

	}

}