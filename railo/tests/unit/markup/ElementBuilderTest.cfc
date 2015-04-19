import craft.markup.ElementBuilder;
import craft.markup.Scope;

component extends="tests.MocktorySpec" {

	function run() {

		describe("ElementBuilder", function () {

			beforeEach(function () {
				objectProvider = mock("ObjectProvider")
				tagRegistry = mock({
					$class: "TagRegistry",
					get: objectProvider
				})

				childScope = mock("Scope")
				parentScope = mock({
					$class: "Scope",
					spawn: childScope
				})
				childScope.$property("parent", "this", parentScope)
				parentScope.$property("parent", "this", null)

				elementBuilder = new ElementBuilder(tagRegistry, parentScope)

			})

			describe(".build", function () {

				describe("constructing", function () {

					var create = function (ref, hasParent) {
						var element = mock({
							$class: "Element",
							ref: arguments.ref,
							hasParent: arguments.hasParent,
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
						element = create("ref", false)
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
								create("child1", true),
								create("child2", true),
								create("child3", true),
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
								var parent = children[2]
								grandchildren = [
									create("grandchild1", true),
									create("grandchild2", true),
									create("grandchild3", true)
								]
								parent.children = grandchildren

								until = parent.children[3] // The last element to be traversed.
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
						objectProvider = mock({
							$class: "ObjectProvider",
							instance: element
						})
						mock({
							$object: tagRegistry,
							get: objectProvider
						})

						document = XMLNew()
					})

					it("should create the element", function () {
						document.xmlRoot = XMLElemNew(document, "namespace", "node")

						var result = elementBuilder.build(document)

						verify(tagRegistry, {
							get: {
								$args: ["namespace"],
								$times: 1
							}
						})
						verify(objectProvider, {
							instance: {
								$args: ["node", {textContent: ""}],
								$times: 1
							}
						})
					})

					it("should create the element using the attributes", function () {
						document.xmlRoot = XMLElemNew(document, "namespace", "node")
						document.xmlRoot.xmlAttributes = {
							ref: "ref",
							name: "name"
						}

						var result = elementBuilder.build(document)

						verify(tagRegistry, {
							get: {
								$args: ["namespace"],
								$times: 1
							}
						})
						verify(objectProvider, {
							instance: {
								$args: ["node", {ref: "ref", name: "name", textContent: ""}],
								$times: 1
							}
						})
					})

					it("should create the tree of elements", function () {
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
						verify(tagRegistry, {
							get: {
								$args: ["namespace"],
								$times: 3
							}
						})
						verify(objectProvider, {
							instance: [
								{
									$args: ["node", {textContent: ""}],
									$times: 1
								},
								{
									$args: ["node", {ref: "ref1", textContent: ""}],
									$times: 1
								},
								{
									$args: ["node", {ref: "ref2", textContent: ""}],
									$times: 1
								}
							]
						})

					})

				})

			})

		})

	}

}