import craft.content.Content;
import craft.content.Document;
import craft.content.DocumentLayout;
import craft.content.Layout;
import craft.content.LayoutContent;
import craft.content.Placeholder;
import craft.content.Section;

import craft.output.ViewFactory;

import craft.util.ClassFinder;
import craft.util.ObjectHelper;

component {

	public void function init(required ViewFactory viewFactory) {
		this.viewFactory = arguments.viewFactory
		this.componentFinder = new ClassFinder()
		this.objectHelper = new ObjectHelper()
	}

	public Content function create(required String name, Struct properties = {}) {

		var className = this.componentFinder.get(arguments.name)
		var component = CreateObject(className)

		// Inject the view factory.
		component.setViewFactory = this.__setViewFactory__
		component.getViewFactory = this.__getViewFactory__

		component.setViewFactory(this.viewFactory)

		this.objectHelper.initialize(component, arguments.properties)

		return component;
	}

	public void function addMapping(required String mapping) {
		this.componentFinder.addMapping(arguments.mapping)
	}

	public void function removeMapping(required String mapping) {
		this.componentFinder.removeMapping(arguments.mapping)
	}

	public Document function createDocument(required LayoutContent layout) {
		return new Document(arguments.layout);
	}

	public DocumentLayout function createDocumentLayout(required LayoutContent layout) {
		return new DocumentLayout(arguments.layout);
	}

	public Layout function createLayout(required Section section) {
		return new Layout(arguments.section);
	}

	public Placeholder function createPlaceholder(required String ref) {
		return new Placeholder(arguments.ref);
	}

	public Section function createSection() {
		return new Section();
	}

	// Methods to be injected in new instances.

	private void function __setViewFactory__(required ViewFactory viewFactory) {
		this.viewFactory = arguments.viewFactory
		StructDelete(this, "setViewFactory")
	}

	private ViewFactory function __getViewFactory__() {
		return this.viewFactory;
	}

}