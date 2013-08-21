import craft.core.request.PathMatcher;

component implements="PathMatcher" {

	public void function init(required Boolean matchPath) {
		variables.matchPath = arguments.matchPath
	}

	public Numeric function match(required Array path) {
		return variables.matchPath ? 1 : 0
	}

}