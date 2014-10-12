import craft.content.ComponentFactory;

import craft.markup.ElementFactory;

import craft.util.ObjectHelper;

component implements="ElementFactory" {

	public void function init(required ComponentFactory componentFactory) {
		this.componentFactory = arguments.componentFactory
		this.objectHelper = new ObjectHelper()
	}

	public Element function create(required String className, required Struct attributes, String textContent = "") {

		var element = CreateObject(arguments.className)

		// Inject the component factory.
		element.setComponentFactory = this.__setComponentFactory__
		element.getComponentFactory = this.__getComponentFactory__

		element.setComponentFactory(this.componentFactory)

		// Run the constructor.
		objectHelper.initialize(element, arguments.attributes)

		return element;
	}

	// Define accessors to be injected in elements. We define them private here, but after injection they are public in the element.
	// We need the setter in case the this scope is made private (with the setting in the administrator).
	// We then can't access the this scope, but we can still inject methods.
	private void function __setComponentFactory__(required ComponentFactory componentFactory) {
		this.componentFactory = arguments.componentFactory
		StructDelete(this, "setComponentFactory")
	}

	private ComponentFactory function __getComponentFactory__() {
		return this.componentFactory;
	}

}