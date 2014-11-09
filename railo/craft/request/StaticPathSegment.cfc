component extends="PathSegment" {

	public void function init(required String pattern, String parameterName = null) {
		super.init(arguments.pattern, arguments.parameterName)
	}

	public Numeric function match(required String[] path) {
		return arguments.path.first() == this.pattern ? 1 : 0;
	}

}