import craft.framework.ContentFactory;
import craft.framework.DefaultElementFactory;
import craft.framework.ViewFactory;

import craft.markup.DirectoryBuilder;
import craft.markup.FileBuilder;
import craft.markup.TagRepository;

import craft.output.CFMLRenderer;
import craft.output.RenderVisitor;

import craft.request.Context;

component extends="testbox.system.BaseSpec" {

	function beforeAll() {
		mapping = "/tests/integration/markup"
		path = ExpandPath(mapping)
	}

	function run() {

		describe("Rendering markup documents", function () {

			beforeEach(function () {
				templateRenderer = new CFMLRenderer()
				viewFactory = new ViewFactory(templateRenderer)
				contentFactory = new ContentFactory(viewFactory)
				elementFactory = new DefaultElementFactory(contentFactory)
				tagRepository = new TagRepository(elementFactory)

				templateRenderer.addMapping(mapping & "/templates")
				contentFactory.addMapping(mapping & "/components")
				tagRepository.register(mapping & "/elements")
				tagRepository.register("/craft/markup/library")

				context = CreateObject("Context") // Create a stub.
			})

			it("should render the element using templates", function () {
				var builder = new FileBuilder(tagRepository)
				var path = path & "/markup/template/element.xml"

				var element = builder.build(path)
				var component = element.product

				var visitor = new RenderVisitor(context)
				visitor.visitComposite(component)

				// The content should be the concatenation of all refs, in depth first order.
				// Empty composites result in an empty sublist.
				var expected = "root" &
						"leaf1" &
						"composite2" &
							"composite2.1" &
								"leaf2.1.1" &
								"leaf2.1.2" &
							"composite2.1" &
							"leaf2.2" &
							"composite2.3" &
								"" &
							"composite2.3" &
						"composite2" &
						"leaf3" &
					"root"

				expect(visitor.content).toBe(expected)
			})

			it("should render the element using views", function () {
				viewFactory.addMapping(mapping & "/views")

				var builder = new FileBuilder(tagRepository)
				var path = path & "/markup/template/element.xml"

				var element = builder.build(path)
				var component = element.product

				var visitor = new RenderVisitor(context)
				visitor.visitComposite(component)

				// The views just return the model they receive. It contains the ref and children if applicable.
				var expected = {
					ref: "root",
					children: [
						{ref: "leaf1"},
						{
							ref: "composite2",
							children: [
								{
									ref: "composite2.1",
									children: [
										{ref: "leaf2.1.1"},
										{ref: "leaf2.1.2"}
									]
								},
								{ref: "leaf2.2"},
								{
									ref: "composite2.3",
									children: []
								}
							]
						},
						{ref: "leaf3"}
					]
				}

				expect(visitor.content).toBe(expected)
			})

			it("should render the documents using templates", function () {
				var builder = new DirectoryBuilder(tagRepository)
				var path = path & "/markup/template"

				var documents = builder.build(path)

				// We have tested element.xml already in the previous test, so filter that out.
				var results = documents.filter(function (name) {
					return !arguments.name == "element.xml";
				}).map(function (name, element) {
					// Visit the element and return the content.
					var document = documents[name].product
					var visitor = new RenderVisitor(context)

					document.accept(visitor)

					return visitor.content;
				})

				// The documents are nested layouts. Create strings with placeholders in the proper places, and replace them for each expectation.
				var layout = "composite1" &
						"placeholder1.1" &
					"composite1" &
					"leaf2" &
					"composite3" &
						"placeholder3.1" &
					"composite3"
				// documentlayout1.xml fills placeholder1.1 and introduces placeholder1.1.2
				var documentlayout1 = fill(layout, {
					"placeholder1.1": "leaf1.1.1" & "placeholder1.1.2" & "leaf1.1.3"
				})
				// documentlayout2.xml fills placeholder1.1.2 and introduces placeholder1.1.2.2
				var documentlayout2 = fill(documentlayout1, {
					"placeholder1.1.2": "leaf1.1.2.1" & "placeholder1.1.2.2"
				})
				// document.xml fills placeholder 1.1.2.2 and placeholder3.1
				var document = fill(documentlayout2, {
					"placeholder1.1.2.2": "leaf1.1.2.2.1",
					"placeholder3.1": "leaf3.1.1"
				})

				// Any unused placeholders will be empty.
				layout = fill(layout, {"placeholder1.1": "", "placeholder3.1": ""})
				expect(results["layout.xml"]).toBe(layout)

				documentlayout1 = fill(documentlayout1, {"placeholder1.1.2": "", "placeholder3.1": ""})
				expect(results["documentlayout1.xml"]).toBe(documentlayout1)

				documentlayout2 = fill(documentlayout2, {"placeholder1.1.2.2": "", "placeholder3.1": ""})
				expect(results["documentlayout2.xml"]).toBe(documentlayout2)

				// The document has already filled all placeholders.
				expect(results["document.xml"]).toBe(document)
			})

			it("should render the documents using views", function () {
				viewFactory.addMapping(mapping & "/views")

				var builder = new DirectoryBuilder(tagRepository)
				var path = path & "/markup/view"

				var documents = builder.build(path)

				var results = documents.filter(function (name) {
					return !arguments.name == "element.xml";
				}).map(function (name, element) {
					// Visit the element and return the content.
					var document = documents[name].product
					var visitor = new RenderVisitor(context)

					if (IsInstanceOf(document, "Layout")) {
						visitor.visitLayout(document)
					} else if (IsInstanceOf(document, "Document")) {
						// Document and DocumentLayout.
						visitor.visitDocument(document)
					}

					return visitor.content;
				})

				var layout = {
					ref: "layout",
					children: [
						{
							ref: "composite1",
							children: [
								// placeholder1.1
							]
						},
						{ref: "leaf2"},
						{
							ref: "composite3",
							children: [
								// placeholder3.1
							]
						}
					]
				}

				expect(results["layout.xml"]).toBe(layout)

				var documentlayout1 = {
					ref: "documentlayout1",
					children: [
						{ref: "leaf1.1.1"},
						// placeholder1.1.2
						{ref: "leaf1.1.3"}
					]
				}
				// documentlayout1 fills placeholder1.1
				layout.children[1].children.append(documentlayout1)
				expect(results["documentlayout1.xml"]).toBe(layout)

				var documentlayout2 = {
					ref: "documentlayout2",
					children: [
						{ref: "leaf1.1.2.1"}
						// placeholder1.1.2.2
					]
				}
				// documentlayout2 fills placeholder1.1.2
				documentlayout1.children.insertAt(2, documentlayout2)
				expect(results["documentlayout2.xml"]).toBe(layout)

				// document fills 2 placeholders.
				var document1 = {
					ref: "document1",
					children: [
						{ref: "leaf1.1.2.2.1"}
					]
				}
				var document2 = {
					ref: "document2",
					children: [
						{ref: "leaf3.1.1"}
					]
				}

				// placeholder1.1.2.2 is introduced by documentlayout2.
				documentlayout2.children.append(document1)
				// placeholder3.1 is introduced by layout.
				layout.children[3].children.append(document2)

				expect(results["document.xml"]).toBe(layout)
			})

		})

	}

	private String function fill(required String content, required Struct placeholders) {
		return arguments.placeholders.reduce(function (result, placeholder, content) {
			return arguments.result.replace(arguments.placeholder, arguments.content);
		}, arguments.content);
	}

}