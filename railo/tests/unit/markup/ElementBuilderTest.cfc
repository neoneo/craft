import craft.markup.ElementBuilder;
import craft.markup.Scope;

component extends="tests.MocktorySpec" {

	function run() {

		describe("ElementBuilder", function () {

			beforeEach(function () {
				elementFactory = mock({
					$interface: "ElementFactory",
					create: function (required String className, required Struct attributes, String textContent = "") {
						return new TagElement(argumentCollection: arguments.attributes);
					}
				})
				tagRepository = mock({
					$class: "TagRepository",
					get: {
						$args: ["http://neoneo.nl/craft", "node"],
						$returns: {
							class: "node",
							attributes: [{name: "ref", type: "String", required: true}]
						}
					},
					elementFactory: elementFactory
				})

				scope = new Scope()
				elementBuilder = new ElementBuilder(tagRepository, scope)

				// Create a fake xml document for the call to build().
				document = XMLNew()
				document.xmlRoot = XMLElemNew(document, "http://neoneo.nl/craft", "node")
			})

			describe(".build", function () {

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

		})

	}

	// private Element function createElementTree() {
	// 	// Create a tree of elements.
	// 	var root = createElement("root")
	// 	([1, 2, 3]).each(function (index) {
	// 		root.add(createElement("child" & arguments.index))
	// 	})

	// 	var child2 = root.children[2]; // Semicolon needed for parser exception.
	// 	([1, 2, 3]).each(function (index) {
	// 		child2.add(createElement("grandchild" & arguments.index))
	// 	})

	// 	return root;
	// }

	// public void function Instantiate_Should_ThrowIllegalArgumentException_When_MissingAttributes() {
	// 	// The repository already has a mock get method, which returns something unsuitable for this test.
	// 	tagRepository.get("http://neoneo.nl/craft/test", "node").returns({
	// 		class: "node",
	// 		attributes: [
	// 			{name: "ref", type: "String", required: true},
	// 			{name: "attribute1", type: "String"},
	// 			{name: "attribute2", type: "String", required: true}
	// 		]
	// 	})

	// 	builder = new ElementBuilder(tagRepository, new Scope())
	// 	makePublic(builder, "instantiate")

	// 	var document = XMLNew()
	// 	var node = XMLElemNew(document, "http://neoneo.nl/craft/test", "node")
	// 	node.xmlAttributes.ref = "ref"

	// 	try {
	// 		builder.instantiate(node)
	// 		fail("exception should have been thrown")
	// 	} catch (IllegalArgumentException e) {
	// 		assertTrue(e.message.startsWith("Attribute"))
	// 		assertTrue(e.message contains "attribute2")
	// 	}

	// }

	// public void function Instantiate_Should_ThrowIllegalArgumentException_When_InvalidNumeric() {
	// 	testAttributeDatatype("Numeric", "a", "42")
	// }

	// public void function Instantiate_Should_ThrowIllegalArgumentException_When_InvalidDate() {
	// 	testAttributeDatatype("Date", "b", "2000-01-01")
	// }

	// public void function Instantiate_Should_ThrowIllegalArgumentException_When_InvalidBoolean() {
	// 	testAttributeDatatype("Boolean", "c", "false")
	// }

	// private void function testAttributeDatatype(required String datatype, required String falseValue, required String trueValue) {
	// 	tagRepository.get("http://neoneo.nl/craft/test", "node").returns({
	// 		class: "node",
	// 		attributes: [
	// 			{name: "ref", type: "String"},
	// 			{name: arguments.datatype, type: arguments.datatype}
	// 		]
	// 	})

	// 	builder = new ElementBuilder(tagRepository, new Scope())
	// 	makePublic(builder, "instantiate")

	// 	var document = XMLNew()
	// 	var node = XMLElemNew(document, "http://neoneo.nl/craft/test", "node")
	// 	node.xmlAttributes.ref = "ref"
	// 	node.xmlAttributes[arguments.datatype] = arguments.falseValue

	// 	try {
	// 		builder.instantiate(node)
	// 		fail("exception should have been thrown")
	// 	} catch (IllegalArgumentException e) {
	// 		assertTrue(e.message.startsWith("Invalid"))
	// 	}

	// 	node.xmlAttributes[arguments.datatype] = arguments.trueValue
	// 	builder.instantiate(node)

	// }

	// public void function Instantiate_Should_UseDefault_When_NoValue() {
	// 	tagRepository.get("http://neoneo.nl/craft/test", "node").returns({
	// 		class: "node",
	// 		attributes: [
	// 			{name: "ref", type: "String"},
	// 			{name: "attribute1", type: "String", default: "somevalue"},
	// 			{name: "attribute2", type: "String"},
	// 		]
	// 	})

	// 	builder = new ElementBuilder(tagRepository, new Scope())
	// 	makePublic(builder, "instantiate")

	// 	var document = XMLNew()
	// 	var node = XMLElemNew(document, "http://neoneo.nl/craft/test", "node")
	// 	node.xmlAttributes.ref = "ref"
	// 	node.xmlAttributes.attribute2 = "othervalue"

	// 	var element = builder.instantiate(node)

	// 	assertEquals("somevalue", element.attribute1)
	// 	assertEquals("othervalue", element.attribute2)
	// }

	// public void function Instantiate_Should_ReturnElementTree() {
	// 	builder = new ElementBuilder(tagRepository, new Scope())
	// 	makePublic(builder, "instantiate")

	// 	var document = XMLNew()

	// 	var createNode = function (required String ref) {
	// 		var node = XMLElemNew(document, "http://neoneo.nl/craft", "node")
	// 		node.xmlAttributes.ref = arguments.ref
	// 		return node;
	// 	}

	// 	var rootNode = createNode("root")
	// 	var childNode1 = createNode("child1")
	// 	var childNode2 = createNode("child2")
	// 	var childNode3 = createNode("child3")
	// 	var grandchildNode1 = createNode("grandchild1")
	// 	var grandchildNode2 = createNode("grandchild2")
	// 	var grandchildNode3 = createNode("grandchild3")

	// 	childNode2.xmlChildren = [grandchildNode1, grandchildNode2, grandchildNode3]
	// 	rootNode.xmlChildren = [childNode1, childNode2, childNode3]

	// 	// Test.
	// 	var root = builder.instantiate(rootNode)
	// 	assertEquals(rootNode.xmlAttributes.ref, root.ref)
	// 	// assertEquals(rootNode.xmlName, root.name)

	// 	var children = root.children
	// 	var child1 = children[1]
	// 	assertEquals(childNode1.xmlAttributes.ref, child1.ref)
	// 	// assertEquals(rootNode.xmlName, root.name)

	// 	var child2 = children[2]
	// 	assertEquals(childNode2.xmlAttributes.ref, child2.ref)
	// 	// assertEquals(childNode2.xmlName, child2.name)

	// 	var child3 = children[3]
	// 	assertEquals(childNode3.xmlAttributes.ref, child3.ref)
	// 	// assertEquals(childNode3.xmlName, child3.name)

	// 	var grandchildren = child2.children

	// 	var grandchild1 = grandchildren[1]
	// 	assertEquals(grandchildNode1.xmlAttributes.ref, grandchild1.ref)
	// 	// assertEquals(grandchildNode1.xmlName, grandchild1.name)
	// 	var grandchild2 = grandchildren[2]
	// 	assertEquals(grandchildNode2.xmlAttributes.ref, grandchild2.ref)
	// 	// assertEquals(grandchildNode2.xmlName, grandchild2.name)
	// 	var grandchild3 = grandchildren[3]
	// 	assertEquals(grandchildNode3.xmlAttributes.ref, grandchild3.ref)
	// 	// assertEquals(grandchildNode3.xmlName, grandchild3.name)

	// }

	// public void function Instantiate_Should_HandleMultipleNamespaces() {
	// 	tagRepository.get("http://neoneo.nl/craft/test", "t:composite").returns({
	// 		class: "node",
	// 		attributes: [{name: "ref", type: "String", required: true}]
	// 	})

	// 	var builder = new ElementBuilder(tagRepository, new Scope())
	// 	makePublic(builder, "instantiate")

	// 	var document = XMLNew()
	// 	var rootNode = XMLElemNew(document, "http://neoneo.nl/craft/test", "t:composite")
	// 	rootNode.xmlAttributes.ref = "root"
	// 	var childNode = XMLElemNew(document, "http://neoneo.nl/craft", "node")
	// 	childNode.xmlAttributes.ref = "child"

	// 	rootNode.xmlChildren = [childNode]

	// 	var root = builder.instantiate(rootNode)
	// 	assertEquals(rootNode.xmlAttributes.ref, root.ref)

	// 	var child = root.children[1]
	// 	assertEquals(childNode.xmlAttributes.ref, child.ref)

	// }

}