import craft.output.ViewFactory;

import craft.util.ClassFinder;

component {

	public void function init(required ViewFactory viewFactory) {
		this.viewFactory = arguments.viewFactory
		this.componentFinder = new ClassFinder()
	}

	public Component function create(required String name, Struct properties = {}) {

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

	// Methods to be injected in new instances.

	private void function __setViewFactory__(required ViewFactory viewFactory) {
		this.viewFactory = arguments.viewFactory
		StructDelete(this, "setViewFactory")
	}

	private ViewFactory function __getViewFactory__() {
		return this.viewFactory;
	}

}