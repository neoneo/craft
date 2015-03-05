component extends = PathSegment {

	public void function init() {
		// No constructor arguments.
		super.init()
	}

	public Numeric function match(required String[] path) {
		// This path segment never matches anything.
		return 0;
	}

}