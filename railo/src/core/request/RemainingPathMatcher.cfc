component implements="PathMatcher" {

	public void function init(required PathMatcher pathMatcher) {
		variables.pathMatcher = arguments.pathMatcher
	}

	public Numeric function match(required Array path) {
		return variables.pathMatcher.match(arguments.path) > 0 ? arguments.path.len() : 0
	}

}