import craft.util.*;

component extends="testbox.system.BaseSpec" {

	function run() {

		describe("ObjectHelper", function () {
			beforeEach(function () {
				objectHelper = new ObjectHelper()
			})

			describe(".methodExists for class without inheritance", function () {

				beforeEach(function () {
					metadata = GetComponentMetadata("classes.BaseClass")
				})

				describe("and explicit methods", function () {

					it("should return true if the method has a high enough access modifier", function () {
						// Public method:
						expect(objectHelper.methodExists(metadata, "publicMethod", "public")).toBeTrue()
						// The method is public, so is also accessible if we have private or package access to the class.
						expect(objectHelper.methodExists(metadata, "publicMethod", "package")).toBeTrue("if package access is required, a public method should be accessible")
						expect(objectHelper.methodExists(metadata, "publicMethod", "private")).toBeTrue("if private access is required, a public method should be accessible")
						// Private method:
						expect(objectHelper.methodExists(metadata, "privateMethod", "private")).toBeTrue()

					})

					it("should return false if the method does not have a high enough access modifier", function () {
						// Remote access is not allowed for the public method.
						expect(objectHelper.methodExists(metadata, "publicMethod", "remote")).toBeFalse("if remote access is required, public access is not enough")

						// None of the other access levels would allow execution of the method.
						expect(objectHelper.methodExists(metadata, "privateMethod", "package")).toBeFalse()
						expect(objectHelper.methodExists(metadata, "privateMethod", "public")).toBeFalse()
						expect(objectHelper.methodExists(metadata, "privateMethod", "remote")).toBeFalse()

					})

					it("should return false if the method does not exist", function () {
						// Test with private access requirement, because any method that exists would return true then.
						expect(objectHelper.methodExists(metadata, "nonExistingMethod", "private")).toBeFalse()
					})

				})

				describe("and generated methods", function () {

					it("should return true if the property exists unless remote access is required", function () {
						expect(objectHelper.methodExists(metadata, "getProperty1", "public")).toBeTrue()
						expect(objectHelper.methodExists(metadata, "getProperty1", "package")).toBeTrue()
						expect(objectHelper.methodExists(metadata, "getProperty1", "private")).toBeTrue()
						expect(objectHelper.methodExists(metadata, "getProperty1", "remote")).toBeFalse()
					})

					it("should return false if the property exists but has no accessor", function () {
						// There is no setter for property2.
						expect(objectHelper.methodExists(metadata, "setProperty2", "private")).toBeFalse()
					})

					it("should return false if the property does not exist", function () {
						expect(objectHelper.methodExists(metadata, "setNonExistingProperty", "private")).toBeFalse()
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
						expect(objectHelper.methodExists(metadata, "publicMethod", "private")).toBeTrue()
						expect(objectHelper.methodExists(metadata, "packageMethod", "private")).toBeTrue()
						expect(objectHelper.methodExists(metadata, "packageMethod", "package")).toBeTrue()
						expect(objectHelper.methodExists(metadata, "remoteMethod", "private")).toBeTrue()
						expect(objectHelper.methodExists(metadata, "remoteMethod", "package")).toBeTrue()
						expect(objectHelper.methodExists(metadata, "remoteMethod", "public")).toBeTrue()
						expect(objectHelper.methodExists(metadata, "remoteMethod", "remote")).toBeTrue()

					})

					it("should return false if the method does not have a high enough access modifier", function () {
						expect(objectHelper.methodExists(metadata, "publicMethod", "package")).toBeFalse()
						expect(objectHelper.methodExists(metadata, "publicMethod", "public")).toBeFalse()
						expect(objectHelper.methodExists(metadata, "publicMethod", "remote")).toBeFalse()
						expect(objectHelper.methodExists(metadata, "packageMethod", "public")).toBeFalse()
						expect(objectHelper.methodExists(metadata, "packageMethod", "remote")).toBeFalse()
					})

					it("should return false if the method does not exist", function () {
						expect(objectHelper.methodExists(metadata, "nonExistingMethod", "private")).toBeFalse()
					})

				})

				describe("and generated methods", function () {

					it("should return true if the property exists unless remote access is required", function () {
						expect(objectHelper.methodExists(metadata, "getProperty1", "public")).toBeTrue()
						expect(objectHelper.methodExists(metadata, "getProperty1", "package")).toBeTrue()
						expect(objectHelper.methodExists(metadata, "getProperty1", "private")).toBeTrue()
						expect(objectHelper.methodExists(metadata, "getProperty1", "remote")).toBeFalse()

						// The setter for property2 should now exist.
						expect(objectHelper.methodExists(metadata, "setProperty2", "private")).toBeTrue()
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

					expect(objectHelper.extends(metadata, metadata.name)).toBeTrue()
					expect(objectHelper.extends(submetadata, metadata.name)).toBeTrue()
					expect(objectHelper.extends(subsubmetadata, metadata.name)).toBeTrue()
					expect(objectHelper.extends(subsubmetadata, submetadata.name)).toBeTrue()
				})

				it("should return false if the given metadata does not belong to a subclass", function () {
					expect(objectHelper.extends(metadata, submetadata.name)).toBeFalse()
					expect(objectHelper.extends(metadata, subsubmetadata.name)).toBeFalse()
					expect(objectHelper.extends(submetadata, subsubmetadata.name)).toBeFalse()
				})

			})

			describe(".collectProperties", function () {

				it("should return the properties defined in the class and its superclasses", function () {
					var metadata = GetComponentMetadata("classes.SubSubClass")
					var properties = objectHelper.collectProperties(metadata)

					// The properties are returned in the order of definition, from subclass to superclass
					expect(properties).toBe([
						{name: "property2", type: "String", setter: "yes", default: "property"},
						{name: "property4", type: "String"},
						{name: "property3", type: "String"},
						{name: "property1", type: "String"}
					])
				})

			})

			describe(".initialize", function () {

				it("should set property values if there is no constructor", function () {
					// The base class has no constructor, and two properties of which one has a setter.
					var base = CreateObject("classes.BaseClass")

					objectHelper.initialize(base, {property1: "property1", property2: "property2"})

					expect(base.property1).toBe("property1")
					expect(base.property2).toBeNull() // There is no setter for property2.
				})

				it("should set property values if there is a public constructor", function () {
					// The sub class has a public constructor that sets property3. The other properties should not be set.
					var sub = CreateObject("classes.SubClass")

					objectHelper.initialize(sub, {property1: "property1", property2: "property2", property3: "property3"})

					expect(sub.property1).toBeNull()
					expect(sub.property2).toBeNull()
					expect(sub.property3).toBe("property3")
				})

				it("should set property values if there is a private constructor", function () {
					// The sub sub class has a private constructor. All 4 properties have setters.
					var subsub = CreateObject("classes.SubSubClass")

					objectHelper.initialize(subsub, {property1: "property1", property2: "property2", property3: "property3", property4: "property4"})

					expect(subsub.property1).toBe("property1")
					expect(subsub.property2).toBe("property2")
					expect(subsub.property3).toBe("property3")
					expect(subsub.property4).toBe("property4")
				})

			})

		})

	}

}