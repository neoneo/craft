component implements="PathMatcher" {

	public void function init(required String name) {
		variables._name = arguments.name
	}

	public Numeric function match(required Array path) {
		return arguments.path.first() == variables._name ? 1 : 0
	}

}