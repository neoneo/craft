component {

	public void function init(required CommandFactory factory) {
		variables._factory = arguments.factory
		variables._root = new RootPathSegment()

		// A struct that maps paths to path segments.
		variables._pathSegments = {"": variables._root}

		variables._indentLevels = []
	}

	/**
	 * Parses a single route and returns the corresponding `PathSegment`.
	 */
	public PathSegment function parse(required String route) {

		// Split the route into words using spaces and tabs as delimiters.
		var words = arguments.route.listToArray(" #Chr(9)#")

		// A route has the form: <method> ([">"*] <path> | ".") <command identifier> [(-> <command identifier> | => <path>)]*

		try {
			var pos = 1
			var method = words[pos]

			pos += 1
			var path = words[pos]

			// Find out the path segment relative to which the path should be interpreted.
			var pathSegment = null

			if (path == ".") {
				pathSegment = variables._indentLevels.last()
				path = ""
			} else if (path.startsWith(">")) {
				var level = path.len()
				pathSegment = variables._indentLevels[level]

				pos += 1
				path = words[pos]

				// If the indent level decreased, remove everything after the current level.
				if (level < variables._indentLevels.len()) {
					variables._indentLevels = variables._indentLevels.slice(1, level)
				}

			} else {
				// No indents.
				pathSegment = variables._root
				variables._indentLevels.clear()
			}

			// The command identifier.
			pos += 1
			var identifier = words[pos]

		} catch (Expression e) {
			/*
				Possible errors:
				- Another word was expected but not found.
				- The indent level does not exist.
			*/
			rethrow;
		}

		// Split the path into segments and add path segments that don't exist yet.
		path.listToArray("/").each(function (segment) {
			// Parse the segment for a parameter name.
			var pattern = arguments.segment
			var parameterName = null

			if (arguments.segment.startsWith("@")) {
				pattern = ".*"
				parameterName = arguments.segment.removeChars(1, 1)
			} else if (arguments.segment contains "@") {
				// Split the segment at any @ sign that is not escaped by a \, unless that \ is itself escaped.
				// This uses a Java regex, which supports negative lookbehind.
				var parts = arguments.segment.split("(?<!(?<!\\)\\)@")
				// We accept 1 or 2 parts.
				if (parts.len() > 2) {
					Throw("Invalid path segment '#arguments.segment#'", "IllegalArgumentException", "Escape @ signs with a \ where necessary")
				}
				var pattern = parts[1].reReplace("\\([@\\])", "\1", "all")
				if (parts.len() == 2) {
					parameterName = parts[2]
				}
			}

			// Try to find a path segment that has this pattern.
			var children = pathSegment.children()
			var index = children.find(function (child) {
				return arguments.child.pattern() == pattern
			})
			if (index > 0) {
				pathSegment = children[index]
			} else {
				// There is no path segment for this pattern, so create it.
				var child = createPathSegment(pattern, parameterName)
				pathSegment.addChild(child)
				// Continue with the child for the next iteration.
				pathSegment = child
			}
		})

		// The pathSegment variable now contains the path segment that corresponds to the route.
		// Push the path segment on the indent levels in case the next parse uses indents.
		variables._indentLevels.append(pathSegment)

		var command = variables._factory.supply(identifier)
		pathSegment.setCommand(command, method)

		return pathSegment
	}

	/**
	 * Creates the `PathSegment` that listens to the given pattern. The pattern can be:
	 *
	 * - a fixed string
	 * - a regular expression
	 * - *
	 */
	private PathSegment function createPathSegment(required String pattern, String parameterName = null) {

		if (arguments.pattern == "*") {
			return new EntirePathSegment(arguments.parameterName)
		} else {
			// If the pattern contains some 'specific' regex character, we assume it is a regex.
			if (arguments.pattern.findOneOf("[](){}*+?") > 0) {
				return new DynamicPathSegment(arguments.pattern, arguments.parameterName)
			} else {
				return new StaticPathSegment(arguments.pattern, arguments.parameterName)
			}
		}

	}

}