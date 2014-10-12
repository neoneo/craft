import craft.output.TemplateRenderer;
import craft.output.View;

import craft.util.ClassFinder;

component {

	public void function init(required TemplateRenderer templateRenderer) {
		this.templateRenderer = arguments.templateRenderer
		this.viewFinder = new ClassFinder()
	}

	public void function addMapping(required String mapping) {
		this.viewFinder.addMapping(arguments.mapping)
	}

	public void function removeMapping(required String mapping) {
		this.viewFinder.removeMapping(arguments.mapping)
	}

	public void function clearMappings() {
		this.viewFinder.clear()
	}

	/**
	 * Searches for a `View` class of the given name and creates it. If no `View` class has this name,
	 * creates a `TemplateView` that interprets the name as a template.
	 */
	public View function create(required String name, Struct properties = {}) {
		if (this.viewFinder.exists(arguments.name)) {
			var className = this.viewFinder.get(arguments.name)

			var instance = CreateObject(className)
			instance.templateRenderer = this.templateRenderer

			this.objectHelper.initialize(instance, arguments.properties)

			return instance;
		} else {
			var instance = CreateObject("TemplateView")
			instance.templateRenderer = this.templateRenderer

			instance.init(arguments.name, arguments.properties)

			return instance;
		}
	}

}