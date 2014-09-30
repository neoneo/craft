component {

	public void function init(required ViewFinder viewFinder, required ViewRenderer viewRenderer) {
		this.viewFinder = arguments.viewFinder
		this.viewRenderer = arguments.viewRenderer
	}

	/**
	 * Searches for a `View` component of the given name and creates it. If no `View` component has this name,
	 * tries to find a template of that name and creates a `TemplateView` that wraps it.
	 *
	 * The optional struct is passed on to the `View` instance as argument collection to `View.configure()`, or
	 * (in the case) of a `TemplateView`), as additional properties.
	 */
	public View function create(required String name, Struct properties = {}) {
		if (this.viewFinder.exists(arguments.name)) {
			var viewComponent = this.viewFinder.get(arguments.name)

			return new "#viewComponent#"(this.viewRenderer, arguments.properties);
		} else {
			return new TemplateView(this.viewRenderer, {template: arguments.name, properties: arguments.properties});
		}
	}

}