component implements="PathMatcher" {

	public void function init(String name = "index") {
		variables._name = arguments.name
	}

	public Numeric function match(required String[] path) {
		// Match if the path is empty, or has one segment with the name of the root.
		return arguments.path.isEmpty() || arguments.path.len() == 1 && arguments.path.first() == variables._name ? 1 : 0
	}

}