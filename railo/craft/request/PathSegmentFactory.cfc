component {

	/**
	 * Creates the `PathSegment` that listens to the given pattern.
	 */
	public PathSegment function create(required String pattern, String parameterName = null) {

		if (arguments.pattern == "/") {
			return new RootPathSegment()
		} else if (arguments.pattern == "*") {
			return new EntirePathSegment(arguments.parameterName)
		} else {
			// If the pattern contains some 'specific' regex character, we assume it is a regex.
			if (arguments.pattern.findOneOf("[({*+?|") > 0) {
				return new DynamicPathSegment(arguments.pattern, arguments.parameterName)
			} else {
				return new StaticPathSegment(arguments.pattern, arguments.parameterName)
			}
		}

	}

}