component implements="PathMatcher" {

	public void function init(String name = "index") {
		variables.name = arguments.name
	}

	public Numeric function match(required Array path) {
		return arguments.path.isEmpty() || arguments.path.first() == variables.name ? 1 : 0
	}

}