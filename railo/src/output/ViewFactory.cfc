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
	 * Searches for a `View` component of the given name and creates it. If no `View` component has this name,
	 * creates a `TemplateView` that interprets the name as a template.
	 *
	 * The optional struct is passed on to the `View` instance as argument collection to `View.configure()`, or
	 * (in the case of a `TemplateView`), as additional properties.
	 */
	public View function create(required String name, Struct properties = {}) {
		if (this.viewFinder.exists(arguments.name)) {
			var className = this.viewFinder.get(arguments.name)

			return new "#className#"(this.templateRenderer, arguments.properties);
		} else {
			return new TemplateView(this.templateRenderer, {template: arguments.name, properties: arguments.properties});
		}
	}

}