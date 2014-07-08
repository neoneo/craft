component implements="PathMatcher" {

	public void function init(required String pattern) {
		variables._pattern = arguments.pattern
	}

	public Numeric function match(required String[] path) {
		return IsValid("regex", arguments.path.first(), variables._pattern) ? 1 : 0
	}

}