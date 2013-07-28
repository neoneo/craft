component implements="PathMatcher" {

	public void function init(required String name) {
		variables.name = arguments.name
	}

	public Numeric function match(required Array path) {
		return arguments.path.first() == variables.name ? 1 : 0
	}

}