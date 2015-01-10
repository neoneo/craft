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

				builder = new DirectoryBuilder(tagRepository)

				context = CreateObject("Context") // Create a stub.
			})

			it("should render the element using templates", function () {
				var builder = new FileBuilder(tagRepository)
				var path = path & "/content/valid/element.xml"

				var element = builder.build(path)
				var component = element.product

				var visitor = new RenderVisitor(context)
				visitor.visitComposite(component)

				dump(visitor.content)
			})

			it("should render the documents using templates", function () {
				var path = path & "/content/valid"
				var documents = builder.build(path)

				for (var name in documents) {
					if (!name.endsWith("element.xml")) {
						var document = documents[name].product
						var visitor = new RenderVisitor(context)

						switch (GetMetadata(document).name.listLast(".")) {
							case "Composite":
								visitor.visitComposite(document)
								break;
							case "Layout":
								visitor.visitLayout(document)
								break;
							case "Document":
							case "DocumentLayout":
								visitor.visitDocument(document)
								break;

						}
						// dump(var = visitor.content, label = GetMetadata(document).name.listLast("."))
					}
				}
			})

		})

	}

}