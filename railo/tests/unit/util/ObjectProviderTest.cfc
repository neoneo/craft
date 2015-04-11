import craft.util.ObjectProvider;

component extends="tests.MocktorySpec" {

	function beforeAll() {
		super.beforeAll();

		mapping = "/tests/unit/util/objectprovider"
		dotMapping = mapping.listChangeDelims(".", "/")
	}

	function run() {

		describe("ObjectProvider", function () {

			describe("without parent", function () {

				beforeEach(function () {
					objectProvider = new ObjectProvider()
				})

				describe(".registerAll", function () {

					beforeEach(function () {
						metadata = mock("Metadata")
						mock(objectProvider).$property("metadata", "this", metadata)
					})

					it("should only register classes with the @transient or @singleton annotation", function () {
						mock({
							$object: metadata,
							list: [
								GetComponentMetadata(dotMapping & ".annotation.ConcreteClass"),
								GetComponentMetadata(dotMapping & ".annotation.Transient"),
								GetComponentMetadata(dotMapping & ".annotation.Singleton")
							]
						})

						objectProvider.registerAll(mapping)

						expect(objectProvider.has("ConcreteClass")).toBeFalse()
						expect(objectProvider.has("Transient")).toBeTrue()
						expect(objectProvider.has("Singleton")).toBeTrue()
					})

					it("should ignore classes with the @abstract annotation", function () {
						mock({
							$object: metadata,
							list: [
								GetComponentMetadata(dotMapping & ".annotation.AbstractClass")
							]
						})

						objectProvider.registerAll(mapping)

						expect(objectProvider.has("ConcreteClass")).toBeFalse()
					})

					it("should collect info about constructor arguments and available setters", function () {
						mock({
							$object: metadata,
							list: [
								GetComponentMetadata(dotMapping & ".info.Class")
							]
						})

						objectProvider.registerAll(mapping)

						expect(objectProvider.has("Class")).toBetrue()
						// Implicitly, this also tests .info().
						// We're not testing inheritance chains here, because this is one of the Metadata tests.
						expect(objectProvider.info("Class")).toBe({
							name: "Class",
							class: dotMapping & ".info.Class",
							singleton: false,
							constructor: [
								{name: "argument1", type: "Numeric", required: true},
								{name: "argument2", type: "String", required: false}
							],
							setters: {
								property1: {type: "String", required: false},
								property2: {type: "Numeric", required: true}
							},
							configure: false
						})
					})

					it("should register several aliases for the class", function () {
						var className = dotMapping & ".info.Class"
						mock({
							$object: metadata,
							list: [
								GetComponentMetadata(className)
							]
						})

						objectProvider.registerAll(mapping)

						// There should be aliases for the class name, and for the class name including some or all of its packages.
						expect(objectProvider.has("Class")).toBetrue()
						expect(objectProvider.has("info.Class")).toBetrue()
						expect(objectProvider.has("objectprovider.info.Class")).toBetrue()
						// Some more aliases should have been created too.
					})

					it("should throw AlreadyBoundException if an object is already registered under the name", function () {
						// If we register the object twice, the name and all aliases should be occupied.
						var className = dotMapping & ".info.Class"
						mock({
							$object: metadata,
							list: [
								GetComponentMetadata(className)
							]
						})

						objectProvider.registerAll(mapping)
						expect(function () {
							objectProvider.registerAll(mapping)
						}).toThrow("AlreadyBoundException")
					})

				})

				describe(".register", function () {

					it("should register any value", function () {
						expect(objectProvider.has("string")).toBeFalse()
						expect(objectProvider.has("number")).toBeFalse()

						objectProvider.registerValue("string", "string")
						objectProvider.registerValue("number", 42)

						// We can't really check these instances from the provider without .instance, we'll test that below.
						expect(objectProvider.has("string")).toBeTrue()
						expect(objectProvider.has("number")).toBeTrue()
					})

				})

				describe(".registerAlias", function () {

					it("should throw NotBoundException if there is no object registered under the original name", function () {
						expect(function () {
							objectProvider.registerAlias("object", 42)
						}).toThrow("NotBoundException")
					})

					it("should register the alias if there is an object registered under the original name", function () {
						objectProvider.registerValue("object1", 42)

						expect(objectProvider.has("object2")).toBeFalse()
						objectProvider.registerAlias("object1", "object2")

						expect(objectProvider.has("object2")).toBeTrue()
					})

					it("should throw AlreadyBoundException if the name is already taken", function () {
						objectProvider.registerValue("object1", 42)
						objectProvider.registerAlias("object1", "object2")

						expect(function () {
							objectProvider.registerAlias("object1", "object2")
						}).toThrow("AlreadyBoundException")
					})

				})

				describe(".instance", function () {

					describe("for registered values", function () {

						it("should return the original object", function () {
							var object = {object: "object"}
							objectProvider.registerValue("object", object)

							var result = objectProvider.instance("object")
							expect(result).toBe(object)
							$assert.isSameInstance(object, result)
						})

						it("should return the original object when requested using an alias", function () {
							var object = {object: "object"}
							objectProvider.registerValue("object1", object)
							objectProvider.registerAlias("object1", "object2")

							var result = objectProvider.instance("object2")
							expect(result).toBe(object)
							$assert.isSameInstance(object, result)
						})

						it("should throw NotBoundException if the object is not registered", function () {
							expect(function () {
								objectProvider.instance("object")
							}).toThrow("NotBoundException")
						})

					})

					describe("for registered classes", function () {

						var setup = function (classNames) {
							mock({
								$object: metadata,
								list: arguments.classNames.map(function (className) {
									return GetComponentMetadata(arguments.className);
								})
							})
							objectProvider.registerAll(mapping & "/instance")
						}

						it("should return an instance of a registered class", function () {
							var className = dotMapping & ".instance.Empty"
							setup([className])

							var result = objectProvider.instance("Empty")
							expect(result).toBeInstanceOf(className)
						})

						it("should return the instance if accessed via an alias", function () {
							var className = dotMapping & ".instance.Empty"
							setup([className])

							// Use one of the aliases registered implicitly:
							var result = objectProvider.instance("instance.Empty")
							expect(result).toBeInstanceOf(className)

							// Map an alias to an alias (just for fun).
							objectProvider.registerAlias("instance.Empty", "vacuous")
							var result = objectProvider.instance("vacuous")
							expect(result).toBeInstanceOf(className)
						})

						it("should cache the instance if it is a singleton", function () {
							// Empty has the @singleton annotation.
							var className = dotMapping & ".instance.Empty"
							setup([className])

							expect(objectProvider.info("Empty").singleton).toBeTrue()

							var result1 = objectProvider.instance("Empty")
							var result2 = objectProvider.instance("Empty")
							expect(result1).toBeInstanceOf(className)
							$assert.isSameInstance(result1, result2)

							// Accessing the object via an alias should also return the same instance.
							var result3 = objectProvider.instance("instance.Empty")
							$assert.isSameInstance(result1, result3)
						})

						it("should inject dependency values", function () {
							var className = dotMapping & ".instance.InjectValues"
							setup([className])

							// Register values for all constructor arguments and properties.
							objectProvider.registerValue("property1", "property1")
							objectProvider.registerValue("property2", 2)
							objectProvider.registerValue("argument1", 1)
							objectProvider.registerValue("argument2", "argument2")

							var result = objectProvider.instance("InjectValues")

							expect(result).toBeInstanceOf(className)
							expect(result.property1).toBe("property1")
							expect(result.property2).toBe(2)
							// The constructor arguments are available as an array in the values property.
							expect(result.values).toBe([1, "argument2"])
						})

						it("should instantiate and inject dependencies", function () {
							var className = dotMapping & ".instance.InjectInstances"
							var emptyClassName = dotMapping & ".instance.Empty"
							var injectValuesClassName = dotMapping & ".instance.InjectValues"
							setup([className, injectValuesClassName, emptyClassName])

							// Register required values for InjectValues.
							objectProvider.registerValue("property2", 2)
							objectProvider.registerValue("argument1", 1)

							// Test.
							var result = objectProvider.instance("InjectInstances")

							expect(result).toBeInstanceOf(className)
							expect(result.empty).toBeInstanceOf(emptyClassName)
							expect(result.injectValues).toBeInstanceOf(injectValuesClassName)
							// Check one of the injected values in InjectValues.
							expect(result.injectValues.property2).toBe(2)
						})

					})

				})

			})

			describe("with parent", function () {

				beforeEach(function () {
					parent = new ObjectProvider()
					child = new ObjectProvider(parent)
				})

				describe(".has", function () {

					it("should also search the parent for the object", function () {
						expect(child.has("object")).toBeFalse()
						parent.registerValue("object", 42)

						expect(child.has("object")).toBeTrue()
					})

					it("should not search the parent if the search is not recursive", function () {
						expect(child.has("object")).toBeFalse()
						parent.registerValue("object", 42)

						expect(child.has("object", false)).toBeFalse()
					})

				})

				describe(".registerAll", function () {

					beforeEach(function () {
						parentMetadata = mock("Metadata")
						mock(parent).$property("metadata", "this", parentMetadata)
						childMetadata = mock("Metadata")
						mock(child).$property("metadata", "this", childMetadata)
					})

					it("should register the class despite it being registered by the parent", function () {
						var className = dotMapping & ".info.Class"
						mock({
							$object: parentMetadata,
							list: [
								GetComponentMetadata(className)
							]
						})
						mock({
							$object: childMetadata,
							list: [
								GetComponentMetadata(className)
							]
						})

						parent.registerAll(mapping)

						expect(function () {
							child.registerAll(mapping)
						}).notToThrow()

						expect(parent.has(className)).toBeTrue()
						expect(child.has(className, false)).toBeTrue()  // false: not recursive
					})

				})

				describe(".register", function () {

					it("should register the object despite it being registered by the parent", function () {
						parent.registerValue("object", 42)
						expect(child.has("object", false)).toBeFalse()

						expect(function () {
							child.registerValue("object", 142)
						}).notToThrow()

						expect(child.has("object", false)).toBeTrue()
					})

				})

				describe(".registerAlias", function () {

					it("should throw NotBoundException despite the original object being registered by the parent", function () {
						parent.registerValue("object1", 42)

						expect(function () {
							child.registerAlias("object1", "object2")
						}).toThrow("NotBoundException")
					})

					it("should register the alias despite it being registered by the parent", function () {
						parent.registerValue("object1", 42)
						parent.registerAlias("object1", "object2")

						expect(function () {
							child.registerValue("object1", 142)
							child.registerAlias("object1", "object2")
						}).notToThrow()

						expect(child.has("object1", false)).toBetrue()
						expect(child.has("object2", false)).toBetrue()
					})

				})

				describe(".info", function () {

					it("should not search the parent for the info", function () {
						metadata = mock("Metadata")
						mock(parent).$property("metadata", "this", metadata)
						mock({
							$object: parentMetadata,
							list: [
								GetComponentMetadata(dotMapping & ".info.Class")
							]
						})
						parent.registerAll(mapping)

						expect(child.has("Class")).toBeTrue()
						expect(function () {
							child.info("Class")
						}).toThrow("NotBoundException")
					})

				})

			})

		})

	}

}