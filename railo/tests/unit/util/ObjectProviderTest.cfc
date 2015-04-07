import craft.util.ObjectProvider;

component extends="tests.MocktorySpec" {

	function beforeAll() {
		super.beforeAll();

		mapping = "/tests/unit/util/objectprovider"
		dotMapping = mapping.listChangeDelims(".", "/")
	}

	function run() {

		describe("ObjectProvider", function () {

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
						scan: [
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
						scan: [
							GetComponentMetadata(dotMapping & ".annotation.AbstractClass")
						]
					})

					objectProvider.registerAll(mapping)

					expect(objectProvider.has("ConcreteClass")).toBeFalse()
				})

				it("should collect info about constructor arguments and available setters", function () {
					mock({
						$object: metadata,
						scan: [
							GetComponentMetadata(dotMapping & ".info.Class")
						]
					})

					objectProvider.registerAll(mapping)

					expect(objectProvider.has("Class")).toBetrue()
					expect(objectProvider.info("Class")).toBe({
						class: dotMapping & ".info.Class",
						singleton: false,
						constructor: [
							{name: "argument1", type: "Numeric", required: true},
							{name: "argument2", type: "String", required: false}
						],
						setters: {
							property1: {type: "String", required: false},
							property2: {type: "Numeric", required: true}
						}
					})
				})

				it("should register several aliases for the class", function () {
					var className = dotMapping & ".info.Class"
					mock({
						$object: metadata,
						scan: [
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
						scan: [
							GetComponentMetadata(className)
						]
					})

					objectProvider.registerAll(mapping)
					expect(function () {
						objectProvider.registerAll(mapping)
					}).toThrow("AlreadyBoundException")
				})

			})

		})

	}

}