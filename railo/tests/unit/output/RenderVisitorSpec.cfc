import craft.output.RenderVisitor;

component extends="tests.MocktorySpec" {

	function run() {

		describe("RenderVisitor", function () {

			beforeEach(function () {
				context = mock({
					$class: "Context",
					requestMethod: "get"
				})

				visitor = new RenderVisitor(context)
			})

			describe(".visitLeaf", function () {

				it("should let the leaf process the request and render the model using its view", function () {
					var model = {key: 1}
					var view = mock({
						$class: "View",
						render: {
							$args: [model],
							$returns: "done",
							$times: 1
						}
					})
					var leaf = mock({
						$class: "Leaf",
						process: {
							$args: [context],
							$returns: model,
							$times: 1
						},
						view: {
							$args: [context],
							$returns: view,
							$times: 1
						}
					})

					// Call the component under test.
					visitor.visitLeaf(leaf)

					verify(leaf)
					verify(view)

					// The visitor should make the rendered output ('done') available.
					expect(visitor.content).toBe("done")
				})

				it("should return no content if the leaf has no view", function () {
					var model = {key: 1}
					var leaf = mock({
						$class: "Leaf",
						process: {
							$args: [context],
							$returns: model,
							$times: 1
						},
						view: {
							$args: [context],
							$returns: null,
							$times: 1
						}
					})

					visitor.visitLeaf(leaf)

					verify(leaf)

					// The rendered content should be null.
					expect(visitor.content).toBeNull()
				})

			})

			describe(".visitComposite", function () {

				it("should let the composite process the request and render the model using its view", function () {
					var model = {key: 1}
					var view = mock({
						$class: "View",
						render: {
							// The visitor modifies the model, so we can't mock the arguments here.
							$returns: "done",
							$times: 1
						}
					})

					var composite = mock({
						$class: "Composite",
						process: {
							$args: [context],
							$returns: model,
							$times: 1
						},
						view: {
							$args: [context],
							$returns: view,
							$times: 1
						},
						traverse: {
							$args: [visitor],
							$times: 1
						}
					})

					visitor.visitComposite(composite)

					verify(composite)
					verify(view)

					expect(visitor.content).toBe("done")
				})

				it("should return no content if the composite has no view", function () {
					var model = {key: 1}
					// Mock a composite without a view, containing a child with a view.
					var child = mock({
						$class: "Leaf",
						process: {
							$args: [context],
							$returns: model,
							$times: 1
						},
						view: {
							$args: [context],
							$returns: {
								$class: "View",
								render: {
									$returns: "done",
									$times: 0
								}
							},
							$times: 0 // The composite has no view, so it should not try to render its children.
						}
					})

					var composite = mock({
						$class: "Composite",
						process: {
							$args: [context],
							$returns: model,
							$times: 1
						},
						view: {
							$args: [context],
							$returns: null,
							$times: 1
						},
						// Stub the traverse method so the child is actually visited.
						traverse: {
							$callback: function () {
								visitor.visitLeaf(child)
							},
							$times: 1
						}
					})

					// Actual test.
					visitor.visitComposite(composite)

					verify(composite)
					verify(child)

					// The rendered content should be null.
					expect(visitor.content).toBeNull()
				})

			})

			describe(".visitLayout", function () {

				it("should forward the call to its section", function () {
					var section = mock({
						$class: "Section",
						accept: {
							$args: [visitor],
							$times: 1
						}
					})
					var layout = mock({
						$class: "Layout",
						section: section
					})

					visitor.visitLayout(layout)

					verify(section)
				})

			})

			describe(".visitDocument", function () {

				it("should forward the call to its layout", function () {
					var layout = mock({
						$class: "Layout",
						accept: {
							$args: [visitor],
							$times: 1
						}
					})
					var document = mock({
						$class: "Document",
						layout: layout
					})
					// Somehow, the sections don't exist unless we access them
					document.sections

					visitor.visitDocument(document)

					verify(layout)
				})

			})

			describe(".visitPlaceholder", function () {

				it("should forward the call to the section if a matching section exists", function () {
					var section = mock({
						$class: "Section",
						accept: null
					})

					// Inject this section for the placeholder 'p2'.
					prepareMock(visitor).$property("sections", "this", {p2: section})

					// Now the actual test.
					var placeholder1 = mock({
						$class: "Placeholder",
						ref: "p1"
					})

					visitor.visitPlaceholder(placeholder1)
					// The section should not have been called, because there is no placeholder 'p1'.
					verify(section, {
						accept: {
							$times: 0
						}
					})

					section.$reset()
					var placeholder2 = mock({
						$class: "Placeholder",
						ref: "p2"
					})
					visitor.visitPlaceholder(placeholder2)
					// Now we expect a call to the section.
					verify(section, {
						accept: {
							$args: [visitor],
							$times: 1
						}
					})

				})

			})

			describe(".visitDocument", function () {

				it("should forward the call to its layout", function () {
					var layout = mock({
						$class: "Layout",
						accept: {
							$args: [visitor],
							$returns: null,
							$times: 1
						}
					})
					var document = mock({
						$class: "Document",
						layout: layout,
						sections: {}
					})

					visitor.visitDocument(document)

					verify(layout)
				})

			})

		})

	}

	// public void function VisitDocument_Should_CallLayoutAccept() {
	// }

	// public void function VisitSectionWithoutComponents_Should_ReturnNoContent() {
	// 	var section = mock(CreateObject("Section"))
	// 	section.traverse = function () {} // No components.

	// 	visitor.visitSection(section)

	// 	// The rendered content should be null.
	// 	var content = visitor.content
	// 	assertTrue(content === null, "content should be null")
	// }

	// public void function VisitSectionWithOneComponent_Should_ReturnComponentContent() {
	// 	var view = mock(CreateObject("stubs.ViewStub"))
	// 		.render("{any}").returns("done") // This is what the component ultimately returns.
	// 	var component = mock(CreateObject("Leaf"))
	// 		.process("{object}").returns({})
	// 		.view("{object}").returns(view)

	// 	var section = mock(CreateObject("Section"))
	// 	section.traverse = function () {
	// 		visitor.visitLeaf(component)
	// 	}

	// 	// Test.
	// 	visitor.visitSection(section)

	// 	component.verify().process("{object}")
	// 	component.verify().view("{object}")
	// 	view.verify().render("{any}")

	// 	var content = visitor.content
	// 	assertEquals("done", content)
	// }

	// public void function VisitSectionWithComponents_Should_ReturnConcatenatedContent_When_SimpleValues() {
	// 	// If the section contains multiple components whose views return simple values, those values should be concatenated.

	// 	var view1 = mock(CreateObject("stubs.ViewStub"))
	// 		.render("{any}").returns("view1")
	// 	var component1 = mock(CreateObject("Leaf"))
	// 		.process("{object}").returns({})
	// 		.view("{object}").returns(view1)

	// 	var view2 = mock(CreateObject("stubs.ViewStub"))
	// 		.render("{any}").returns("view2")
	// 	var component2 = mock(CreateObject("Leaf"))
	// 		.process("{object}").returns({})
	// 		.view("{object}").returns(view2)

	// 	var section = mock(CreateObject("Section"))
	// 	section.traverse = function () {
	// 		visitor.visitLeaf(component1)
	// 		visitor.visitLeaf(component2)
	// 	}

	// 	// Test.
	// 	visitor.visitSection(section)

	// 	component1.verify().process("{object}")
	// 	component1.verify().view("{object}")
	// 	view1.verify().render("{any}")
	// 	component2.verify().process("{object}")
	// 	component2.verify().view("{object}")
	// 	view2.verify().render("{any}")

	// 	var content = visitor.content
	// 	assertEquals("view1view2", content)
	// }

	// public void function VisitSectionWithComponents_Should_ThrowException_When_NotSimpleValues() {
	// 	var view1 = mock(CreateObject("stubs.ViewStub"))
	// 		.render("{any}").returns({key: "view1"}) // Complex value returned by view.
	// 	var component1 = mock(CreateObject("Leaf"))
	// 		.process("{object}").returns({})
	// 		.view("{object}").returns(view1)

	// 	var view2 = mock(CreateObject("stubs.ViewStub"))
	// 		.render("{any}").returns("view2") // This view renders a string.
	// 	var component2 = mock(CreateObject("Leaf"))
	// 		.process("{object}").returns({})
	// 		.view("{object}").returns(view2)

	// 	var section = mock(CreateObject("Section"))
	// 	section.traverse = function () {
	// 		visitor.visitLeaf(component1)
	// 		visitor.visitLeaf(component2)
	// 	}

	// 	// Test.
	// 	try {
	// 		visitor.visitSection(section)
	// 		fail("exception should have been thrown")
	// 	} catch (DatatypeConfigurationException e) {}

	// 	component1.verify().process("{object}")
	// 	component1.verify().view("{object}")
	// 	view1.verify().render("{any}")
	// 	component2.verify().process("{object}")
	// 	component2.verify().view("{object}")
	// 	view2.verify().render("{any}")

	// }

}