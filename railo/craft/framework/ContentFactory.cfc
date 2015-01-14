import craft.content.Component;
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

		this.componentTrait = new trait.Component()
	}

	public void function addMapping(required String mapping) {
		this.componentFinder.addMapping(arguments.mapping)
	}

	public void function removeMapping(required String mapping) {
		this.componentFinder.removeMapping(arguments.mapping)
	}

	public void function clearMappings() {
		this.componentFinder.clear()
	}

	public Component function createComponent(required String name, Struct properties = {}) {

		var className = this.componentFinder.get(arguments.name)
		var component = CreateObject(className)

		// Inject the view factory.
		this.objectHelper.mixin(component, this.componentTrait)
		component.setViewFactory(this.viewFactory)

		this.objectHelper.initialize(component, arguments.properties)

		return component;
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

}