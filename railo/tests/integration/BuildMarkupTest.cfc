import craft.content.Content;
import craft.content.Document;
import craft.content.DocumentLayout;
import craft.content.Layout;
import craft.content.Placeholder;
import craft.content.Section;

import craft.framework.DefaultElementFactory;

import craft.markup.DirectoryBuilder;
import craft.markup.FileBuilder;
import craft.markup.TagRegistry;

import craft.output.CFMLRenderer;

component extends="testbox.system.BaseSpec" {

	function beforeAll() {
		mapping = "/tests/integration/markup"
		path = ExpandPath(mapping)

		// The markup tags should result in specific component types.
		types = {
			composite: GetComponentMetadata("markup.components.Composite").name,
			leaf: GetComponentMetadata("markup.components.Leaf").name,
			document: GetComponentMetadata("Document").name,
			documentlayout: GetComponentMetadata("DocumentLayout").name,
			layout: GetComponentMetadata("Layout").name,
			placeholder: GetComponentMetadata("Placeholder").name,
			section: GetComponentMetadata("Section").name
		}
	}

	function run() {

		describe("Building markup documents", function () {

			beforeEach(function () {
				templateRenderer = new CFMLRenderer()
				elementFactory = new DefaultElementFactory()
				tagRegistry = new TagRegistry(elementFactory)

				tagRegistry.register(mapping & "/elements")
				tagRegistry.register("/craft/markup/library")
			})

			describe("using FileBuilder", function () {

				it("should throw InstantiationException if the document depends on another element", function () {
					var builder = new FileBuilder(tagRegistry)
					var path = path & "/markup/template/document.xml"

					expect(function () {
						builder.build(path)
					}).toThrow("InstantiationException")
				})

				it("should create an element whose product is the content", function () {
					var builder = new FileBuilder(tagRegistry)
					var path = path & "/markup/template/element.xml"

					var element = builder.build(path)

					// The element has constructed a component we're interested in.
					var component = element.product

					var root = XMLParse(FileRead(path)).xmlRoot
					expect(isEquivalent(component, root)).toBeTrue()
				})

			})

			describe("using DirectoryBuilder", function () {

				it("should throw InstantiationException if any document in the directory depends on an unknown element", function () {
					var builder = new DirectoryBuilder(tagRegistry)
					var path = path & "/markup/invalid"

					expect(function () {
						builder.build(path)
					}).toThrow("InstantiationException")
				})

				it("should create an element whose product is the content", function () {
					// The document depends on a tree of layouts that have to be loaded with a DirectoryBuilder.
					var builder = new DirectoryBuilder(tagRegistry)
					var path = path & "/markup/template"

					var documents = builder.build(path)

					expect(documents).notToBeEmpty()

					// Compare the products with the corresponding xml documents.
					DirectoryList(path, false, "path", "*.xml").each(function (path) {
						var document = documents[arguments.path.listLast(server.separator.file)].product
						var root = XMLParse(FileRead(arguments.path)).xmlRoot
						expect(isEquivalent(document, root)).toBeTrue()
					})
				})

			})

		})

	}

	private Boolean function isEquivalent(required Content content, required XML node) {

		var tagName = arguments.node.xmlName.replace(arguments.node.xmlNsPrefix & ":", "")

		// The content should be of the type specified.
		var type = types[tagName]
		if (!IsInstanceOf(arguments.content, type)) {
			Throw("Node #arguments.node.xmlName####arguments.node.xmlAttributes.ref# should produce a component of type #type#");
		}

		if (tagName == "composite" || tagName == "leaf") {
			// The ref attribute should have been passed on to the component.
			if (arguments.node.xmlAttributes.ref != arguments.content.ref) {
				Throw("Node #arguments.node.xmlName####arguments.node.xmlAttributes.ref# should produce a component with this ref");
			}
		}

		// This function can only test cases where nodes and components are in a one to one correspondence.
		var children = null
		if (IsInstanceOf(arguments.content, "craft.content.Component")) {
			if (arguments.content.hasChildren) {
				var children = arguments.content.children
			}
		} else if (tagName == "layout") {
			var children = arguments.content.section.components
		} else if (tagName == "documentlayout" || tagName == "document") {
			var sections = arguments.content.sections
			// sections is a struct where the keys are the placeholder refs. We need the values (in the correct order).
			var children = sections.keyArray().sort("text").map(function (ref) {
				return sections[arguments.ref]
			})
		} else if (tagName == "section") {
			var children = arguments.content.components
		} else {
			Throw("Unknown content instance: #tagName#");
		}

		if (children !== null) {
			var nodes = arguments.node.xmlChildren
			// children is not a CFML array so no member functions.
			return ArrayEvery(children, function (child, index) {
				return isEquivalent(arguments.child, nodes[arguments.index])
			})
		} else {
			return true;
		}
	}

}