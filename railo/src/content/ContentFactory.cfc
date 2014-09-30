import craft.output.ViewFactory;

import craft.util.ClassFinder;

component {

	public void function init(required ViewFactory viewFactory) {
		this.viewFactory = arguments.viewFactory
		this.contentFinder = new ClassFinder()
	}

	public Component function create(required String name, Struct properties = {}) {

		var className = this.contentFinder.get(arguments.name)

		return new "#className#"(this.viewFactory, arguments.properties);
	}

	public void function addMapping(required String mapping) {
		this.contentFinder.addMapping(arguments.mapping)
	}

	public void function removeMapping(required String mapping) {
		this.contentFinder.removeMapping(arguments.mapping)
	}

}