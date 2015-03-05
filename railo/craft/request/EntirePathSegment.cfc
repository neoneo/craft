component extends = PathSegment {

	public void function init(String parameterName = null) {
		super.init(null, arguments.parameterName)
	}

	public Numeric function match(required String[] path) {
		return arguments.path.len()
	}

}