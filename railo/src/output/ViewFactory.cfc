component accessors="true" {

	property TemplateRenderer templateRenderer;

	public void function init(required TemplateFinder templateFinder, required ViewFinder viewFinder) {
		this.templateFinder = arguments.templateFinder
		this.viewFinder = arguments.viewFinder
	}

	/**
	 * Searches for a `View` component of the given name and creates it. If no `View` component has this name,
	 * tries to find a template of that name and creates a `TemplateView` that wraps it.
	 *
	 * The optional struct is passed on to the `View` instance as argument collection to `View.configure()`, or
	 * (in the case) of a `TemplateView`), as additional properties.
	 */
	public View function create(required String name, Struct properties = {}) {

		try {
			var viewComponent = this.viewFinder.get(arguments.name)

			return new "#viewComponent#"(this.templateFinder, this.templateRenderer, arguments.properties);

		} catch (FileNotFoundException e) {
			return new TemplateView(this.templateFinder, this.templateRenderer, arguments.properties);
		}

	}

}