import craft.util.ObjectProvider;

/**
 * @singleton
 */
component {

	public void function init(required ObjectProvider objectProvider) {
		this.objectProvider = arguments.objectProvider

		this.viewFinder = new ClassFinder()
		this.views = CreateObject("java", "java.util.concurrent.ConcurrentHashMap").init() // Maps names to view instances.
	}

	public void function addMapping(required String mapping) {
		this.viewFinder.addMapping(arguments.mapping)
		// Remove all views that are superseded by views in the new mapping.
		StructEach(this.views, function (name, view) {
			var className = this.viewFinder.get(arguments.name)
			if (!IsInstanceOf(arguments.view, className)) {
				StructDelete(this.views, arguments.name)
			}
		})
	}

	public void function removeMapping(required String mapping) {
		this.viewFinder.removeMapping(arguments.mapping)
		// Keep only the views that can still be found (except template views).
		StructEach(this.views, function (name, view) {
			if (!this.viewFinder.exists(arguments.name) && !IsInstanceOf(arguments.view, "TemplateView")) {
				StructDelete(this.views, arguments.name)
			}
		})
	}

	public void function clearMappings() {
		this.viewFinder.clear()
		StructClear(this.views)
	}

	/**
	 * Searches for a `View` class of the given name and creates it. If no `View` class has this name,
	 * creates a `TemplateView` that interprets the name as a template.
	 */
	private View function create(required String name) {
		if (this.viewFinder.exists(arguments.name)) {
			var className = this.viewFinder.get(arguments.name)
			return this.objectProvider.instance(className);
		} else {
			return this.objectProvider.instance("TemplateView", {template: name});
		}
	}

	public View function get(required String name) {
		if (StructKeyExists(this.views, arguments.name)) {
			return this.views[arguments.name];
		}

		var view = this.create(arguments.name)
		this.views[arguments.name] = view

		return view;
	}

}