import craft.output.RenderVisitor;

component extends="tests.MocktorySpec" {

	function run() {

		describe("RenderVisitor", function () {

			beforeEach(function () {
				context = mock({
					$class: "Context",
					requestMethod: "get"
				})
				viewRepository = mock("ViewRepository")

				visitor = new RenderVisitor(context, viewRepository)
			})

			describe(".visitLeaf", function () {

				it("should let the leaf process the request and render the model using its view", function () {
					var model = {key: 1}
					var view = mock({
						$class: "View",
						render: {
							$args: [model, context],
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
							$returns: "view",
							$times: 1
						}
					})
					mock({
						$object: viewRepository,
						get: {
							$args: ["view"],
							$returns: view,
							$times: 1
						}
					})

					// Call the component under test.
					visitor.visitLeaf(leaf)

					verify(leaf)
					verify(viewRepository)
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
							$returns: "view",
							$times: 1
						},
						traverse: {
							$args: [visitor],
							$times: 1
						}
					})
					mock({
						$object: viewRepository,
						get: {
							$args: ["view"],
							$returns: view,
							$times: 1
						}
					})

					visitor.visitComposite(composite)

					verify(composite)
					verify(viewRepository)
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

				it("should let its section process the request", function () {
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

			describe(".visitPlaceholder", function () {

				it("should let the corresponding section process the request if that section exists", function () {
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

				it("should let its layout process the request", function () {
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

			describe(".visitSection", function () {

				it("should result in no content if the section contains no components", function () {
					var section = mock({
						$class: "Section",
						traverse: {
							$args: [visitor],
							$returns: null,
							$times: 1
						}
					})

					visitor.visitSection(section)

					verify(section)
					expect(visitor.content).toBeNull()
				})

				it("should result in content of any type if the section contains a single component", function () {
					var content = {type: "content"}
					var view = mock({
						$class: "View",
						render: content
					})
					var leaf = mock({
						$class: "Leaf",
						process: {},
						view: "view"
					})
					mock({
						$object: viewRepository,
						get: view
					})
					var section = mock({
						$class: "Section",
						traverse: {
							$args: [visitor],
							$callback: function (visitor) {
								arguments.visitor.visitLeaf(leaf)
							},
							$times: 1
						}
					})

					visitor.visitSection(section)

					verify(section)
					expect(visitor.content).toBe(content)
				})

				it("should result in concatenated of generated content if all components generate string content", function () {
					var leaves = [
						mock({
							$class: "Leaf",
							process: {},
							view: "con"
						}),
						mock({
							$class: "Leaf",
							process: {},
							view: "tent"
						})
					]
					mock({
						$object: viewRepository,
						get: [
							{
								$args: ["con"],
								$returns: {
									$class: "View",
									render: "con"
								}
							},
							{
								$args: ["tent"],
								$returns: {
									$class: "View",
									// Return a stringifiable object.
									render: new stubs.StringifiableStub("tent")
								}
							}
						]
					})

					var section = mock({
						$class: "Section",
						traverse: {
							$args: [visitor],
							$callback: function (visitor) {
								arguments.visitor.visitLeaf(leaves[1])
								arguments.visitor.visitLeaf(leaves[2])
							},
							$times: 1
						}
					})

					visitor.visitSection(section)

					verify(section)
					expect(visitor.content).toBe("content")
				})

				it("should throw DatatypeConfigurationException if there are multiple components of which some generate complex content", function () {
					var leaves = [
						mock({
							$class: "Leaf",
							process: {},
							view: "string"
						}),
						mock({
							$class: "Leaf",
							process: {},
							view: "struct"
						})
					]
					mock({
						$object: viewRepository,
						get: [
							{
								$args: ["string"],
								$returns: {
									$class: "View",
									render: "content"
								}
							},
							{
								$args: ["struct"],
								$returns: {
									$class: "View",
									render: {type: "content"}
								}
							}
						]
					})

					var section = mock({
						$class: "Section",
						traverse: {
							$args: [visitor],
							$callback: function (visitor) {
								arguments.visitor.visitLeaf(leaves[1])
								arguments.visitor.visitLeaf(leaves[2])
							},
							$times: 1
						}
					})

					expect(function () {
						visitor.visitSection(section)
					}).toThrow("DatatypeConfigurationException")
					verify(section)
					expect(visitor.content).toBeNull()
				})

			})

		})

	}

}