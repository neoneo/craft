component implements="PathMatcher" {

	public void function init(required PathMatcher pathMatcher) {
		variables._pathMatcher = arguments.pathMatcher
	}

	public Numeric function match(required Array path) {
		return variables._pathMatcher.match(arguments.path) > 0 ? arguments.path.len() : 0
	}

}