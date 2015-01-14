import craft.content.ContentFactory;

import craft.markup.ElementFactory;

import craft.util.ObjectHelper;

component implements="ElementFactory" {

	public void function init(required ContentFactory contentFactory) {
		this.contentFactory = arguments.contentFactory
		this.objectHelper = new ObjectHelper()

		this.elementTrait = new trait.Element()
	}

	public Element function create(required String className, required Struct attributes, String textContent = "") {

		var element = CreateObject(arguments.className)

		// Inject the content factory.
		this.objectHelper.mixin(element, this.elementTrait)
		element.setContentFactory(this.contentFactory)

		// Run the constructor.
		objectHelper.initialize(element, arguments.attributes)

		return element;
	}

}