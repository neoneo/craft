import craft.markup.ElementBuilder;
import craft.markup.Scope;

component extends="tests.MocktorySpec" {

	function run() {

		describe("ElementBuilder", function () {

			beforeEach(function () {
				tagRepository = mock("TagRepository")

				scope = new Scope()
				elementBuilder = new ElementBuilder(tagRepository, scope)

			})

			describe(".build", function () {

				describe("constructing", function () {

					var create = function (ref) {
						var element = mock({
							$class: "Element",
							ref: arguments.ref,
							construct: function () {
								element.constructed = true
							},
							ready: function () {
								return element.constructed ?: false;
							}
						})

						return element;
					}

					beforeEach(function () {
						element = create("ref")
						mock({
							$object: elementBuilder,
							instantiate: function () {
								return element;
							}
						})
						// Create a fake xml document for the call to build().
						document = XMLNew()
						document.xmlRoot = XMLElemNew(document, "namespace", "node")
					})

					describe("a single element", function () {

						it("should construct the element", function () {
							var result = elementBuilder.build(document)

							$assert.isSameInstance(element, result)
							verify(element, {
								// Construct is called with a new scope object, so we test only for a component to be passed in.
								construct: {
									$args: ["{component}"],
									$times: 1
								}
							})
						})

					})

					describe("an element tree", function () {

						beforeEach(function () {
							element.children = [
								create("child1"),
								create("child2"),
								create("child3"),
							]
						})

						it("should construct all elements in the tree", function () {
							var result = elementBuilder.build(document)

							$assert.isSameInstance(element, result)
							expect(element.ready).toBeTrue()
							verify(element, {
								construct: {
									$args: ["{component}"],
									$times: 1
								}
							})

							element.children.each(function (child) {
								expect(arguments.child.ready).toBeTrue()
								verify(arguments.child, {
									construct: {
										$args: ["{component}"],
										$times: 1
									}
								})
							})
						})

						describe("with elements referring to each other", function () {

							beforeEach(function () {
								// Add some elements that wait for other elements to be constructed first.
								children = element.children
								grandchildren = [
									create("grandchild1"),
									create("grandchild2"),
									create("grandchild3")
								]
								children[2].children = grandchildren

								until = children[2].children[3] // The last element to be traversed.
								// The first deferred waits for the last child to finish.
								deferred1 = mock({
									$class: "Element",
									ref: "deferred1",
									construct: function () {
										deferred1.constructed = until.ready
									},
									ready: function () {
										return deferred1.constructed ?: false;
									}
								})
								// The second deferred waits for the first.
								deferred2 = mock({
									$class: "Element",
									ref: "deferred2",
									construct: function () {
										deferred2.constructed = deferred1.ready
									},
									ready: function () {
										return deferred2.constructed ?: false;
									}
								})
								// Add deferred1 to the first child. The build process should pass through here first.
								mock({
									$object: children[1],
									children: [deferred1]
								})
								// Add deferred2 to the last child. In case the algorithm changes, we still have an element whose construction is deferred.
								mock({
									$object: children[3],
									children: [deferred2]
								})
							})

							it("should construct all elements in the tree", function () {
								var result = elementBuilder.build(document)

								expect(element.ready).toBeTrue()
								verify(element, {
									construct: {
										$args: ["{component}"],
										$times: 1
									}
								})
								children.merge(grandchildren).each(function (child) {
									expect(arguments.child.ready).toBeTrue()
									verify(arguments.child, {
										construct: {
											$args: ["{component}"],
											$times: 1
										}
									})
								})
							})

							it("should throw InstantiationException if there is a circular dependency", function () {
								// Deferred2 waits for deferred1. Deferred1 waits for until. Now let until wait for deferred2 to create a loop.
								mock({
									$object: until,
									construct: function () {
										until.constructed = deferred2.ready
									},
									ready: function () {
										return until.constructed ?: false;
									}
								})

								expect(function () {
									elementBuilder.build(document)
								}).toThrow("InstantiationException")
							})

						})

					})

				})

				describe("instantiating", function () {

					beforeEach(function () {
						mock({
							$object: elementBuilder,
							construct: []
						})

						element = mock({
							$class: "Element",
							ready: true
						})
						elementFactory = mock({
							$interface: "ElementFactory",
							create: element
						})

						document = XMLNew()
					})

					it("should create the element", function () {
						mock({
							$object: tagRepository,
							get: {
								$args: ["namespace", "node"],
								// The node metadata is a regular struct.
								$returns: {
									class: "node",
									attributes: []
								}
							},
							elementFactory: {
								$args: ["namespace"],
								$returns: elementFactory
							}
						})

						document.xmlRoot = XMLElemNew(document, "namespace", "node")

						var result = elementBuilder.build(document)

						verify(elementFactory, {
							create: {
								$args: ["node", {}, ""],
								$times: 1
							}
						})
					})

					it("should create the element with the attributes defined in the tag metadata", function () {
						mock({
							$object: tagRepository,
							get: {
								$args: ["namespace", "node"],
								$returns: {
									class: "node",
									attributes: [{name: "ref", type: "String", required: false}]
								}
							},
							// Return a different element factory for each namespace.
							elementFactory: {
								$args: ["namespace"],
								$returns: elementFactory
							}
						})

						document.xmlRoot = XMLElemNew(document, "namespace", "node")
						document.xmlRoot.xmlAttributes = {
							ref: "ref",
							name: "name" // This attribute is not defined in the metadata.
						}

						var result = elementBuilder.build(document)

						verify(elementFactory, {
							create: {
								// Only the defined attributes should be passed to the factory.
								$args: ["node", {ref: "ref"}, ""],
								$times: 1
							}
						})
					})

					it("should create the tree of elements", function () {
						mock({
							$object: tagRepository,
							get: {
								$args: ["namespace", "node"],
								// The node metadata is a regular struct.
								$returns: {
									class: "node",
									attributes: [{name: "ref", type: "String", required: false}]
								}
							},
							elementFactory: {
								$args: ["namespace"],
								$returns: elementFactory
							}
						})

						document.xmlRoot = XMLElemNew(document, "namespace", "node")

						var createNode = function (ref) {
							var node = XMLElemNew(document, "namespace", "node")
							node.xmlAttributes.ref = arguments.ref
							return node;
						}

						document.xmlRoot.xmlChildren = [
							createNode("ref1"),
							createNode("ref2")
						]

						mock({
							$object: element,
							add: NullValue()
						})

						var result = elementBuilder.build(document)

						$assert.isSameInstance(element, result)
						// The factory always returns the same instance, so it has been added to itself twice.
						verify(element, {
							add: {
								$args: [element],
								$times: 2
							}
						})

						verify(elementFactory, {
							create: [
								{
									$args: ["node", {}, ""],
									$times: 1
								},
								{
									$args: ["node", {ref: "ref1"}, ""],
									$times: 1
								},
								{
									$args: ["node", {ref: "ref2"}, ""],
									$times: 1
								}
							]
						})

					})

					describe("validating attributes", function () {

						beforeEach(function () {
							mock({
								$object: tagRepository,
								get: {
									$args: ["namespace", "node"],
									$returns: {
										class: "node",
										attributes: [
											{name: "ref", type: "String", required: true},
											{name: "number", type: "Numeric", required: false, default: 2}
										]
									}
								},
								// Return a different element factory for each namespace.
								elementFactory: {
									$args: ["namespace"],
									$returns: elementFactory
								}
							})
						})

						it("should throw MissingArgumentException if not all required attributes are defined", function () {
							document.xmlRoot = XMLElemNew(document, "namespace", "node")
							document.xmlRoot.xmlAttributes = {}

							expect(function () {
								elementBuilder.build(document)
							}).toThrow("MissingArgumentException")

							document.xmlRoot.xmlAttributes = {ref: "ref"}
							expect(function () {
								elementBuilder.build(document)
							}).notToThrow()
						})

						it("should throw IllegalArgumentException if the datatype of the attributes cannot be validated", function () {
							document.xmlRoot = XMLElemNew(document, "namespace", "node")
							document.xmlRoot.xmlAttributes = {
								ref: "ref",
								number: "nonumber"
							}

							expect(function () {
								elementBuilder.build(document)
							}).toThrow("IllegalArgumentException")

							document.xmlRoot.xmlAttributes = {
								ref: "ref",
								number: 9
							}
							expect(function () {
								elementBuilder.build(document)
							}).notToThrow()
						})

						it("should set default values for undefined attributes", function () {
							document.xmlRoot = XMLElemNew(document, "namespace", "node")
							document.xmlRoot.xmlAttributes = {
								ref: "ref"
							}

							var result = elementBuilder.build(document)

							// Verify that the default value for attribute number was passed with the attributes.
							verify(elementFactory, {
								create: {
									$args: ["node", {ref: "ref", number: 2}, ""],
									$times: 1
								}
							})
						})

					})

				})

			})

		})

	}

}