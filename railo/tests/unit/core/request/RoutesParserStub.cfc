import craft.core.request.*;

component extends="RoutesParser" {

	// Make the root path segment available to the outside.
	public PathSegment function root() {
		return variables._root
	}

	public PathSegment function createPathSegment(required String pattern, String parameterName = null) {
		return super.createPathSegment(arguments.pattern, arguments.parameterName)
	}

}