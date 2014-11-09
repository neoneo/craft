import craft.content.ContentFactory;

import craft.markup.ElementFactory;

import craft.util.ObjectHelper;

component implements="ElementFactory" {

	public void function init(required ContentFactory contentFactory) {
		this.contentFactory = arguments.contentFactory
		this.objectHelper = new ObjectHelper()
	}

	public Element function create(required String className, required Struct attributes, String textContent = "") {

		var element = CreateObject(arguments.className)

		// Inject the component factory.
		element.setContentFactory = this.__setContentFactory__
		element.getContentFactory = this.__getContentFactory__

		element.setContentFactory(this.contentFactory)

		// Run the constructor.
		objectHelper.initialize(element, arguments.attributes)

		return element;
	}

	// Define accessors to be injected in elements. We define them private here, but after injection they are public in the element.
	// We need the setter in case the this scope is made private (with the setting in the administrator).
	// We then can't access the this scope, but we can still inject methods.
	private void function __setContentFactory__(required ContentFactory contentFactory) {
		this.contentFactory = arguments.contentFactory
		StructDelete(this, "setContentFactory")
	}

	private ContentFactory function __getContentFactory__() {
		return this.contentFactory;
	}

}