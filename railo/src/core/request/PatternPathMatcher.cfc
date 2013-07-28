component implements="PathMatcher" accessors="true" {

	public void function init(required String pattern) {
		variables.pattern = arguments.pattern
	}

	public Numeric function match(required Array path) {
		return IsValid("regex", arguments.path.first(), variables.pattern) ? 1 : 0
	}

}