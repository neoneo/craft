import craft.output.ViewFactory;

component {

	public void function init(required ViewFactory viewFactory) {
		this.viewFactory = arguments.viewFactory
	}

	public Component function create(required String name, Struct properties = {}) {
		return new "#arguments.name#"(this.viewFactory, arguments.properties)
	}

}