component {

	public void function init(required CommandFactory factory) {
		variables._factory = arguments.factory
		variables._root = createPathSegment("/")

		// Array of path segments that correspond to the indents in the routes file.
		variables._indentLevels = []
	}

	public PathSegment function root() {
		return variables._root
	}

	public void function read(required String path) {

		FileRead(arguments.path).listToArray(Chr(10)).each(function (route) {
			// Strip off comments.
			var route = Trim(arguments.route.reReplace("##.*$", ""))
			if (!route.isEmpty()) {
				parse(route)
			}
		})

	}

	/**
	 * Parses a single route and returns the corresponding `PathSegment`.
	 */
	public PathSegment function parse(required String route) {

		// Split the route into words using spaces and tabs as delimiters.
		var words = arguments.route.listToArray(" #Chr(9)#")

		// A route has the form: <method> ([">"*] <path> | ".") <command identifier> [(-> <command identifier> | => <path>)]*

		var index = 1
		var method = pick(words, index)

		index += 1
		var path = pick(words, index)

		// Find out the path segment relative to which the path should be interpreted.
		var pathSegment = null

		if (path == ".") {
			if (variables._indentLevels.isEmpty()) {
				Throw("Route '.' cannot be the first route", "NoSuchElementException")
			}
			pathSegment = variables._indentLevels.last()
			path = ""
		} else if (path.startsWith(">")) {
			var level = path.len()
			pathSegment = pick(variables._indentLevels, level)

			index += 1
			path = pick(words, index)

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
		index += 1
		var identifier = pick(words, index)

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
				// We accept 1 or 2 parts. It's a Java array so we can't use member functions.
				if (ArrayLen(parts) > 2) {
					Throw("Invalid path segment '#arguments.segment#'", "IllegalArgumentException", "Escape @ signs with a \ where applicable")
				}
				var pattern = parts[1].reReplace("\\([@\\])", "\1", "all")
				if (ArrayLen(parts) == 2) {
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

	private Any function pick(required Array array, required Numeric index) {
		if (arguments.array.len() < arguments.index) {
			Throw("Number of items does not match", "NoSuchElementException", "Expected #arguments.index# but found #arguments.array.len()#")
		}

		return arguments.array[arguments.index]
	}

	/**
	 * Creates the `PathSegment` that listens to the given pattern.
	 */
	private PathSegment function createPathSegment(required String pattern, String parameterName = null) {

		if (arguments.pattern == "/") {
			return new RootPathSegment()
		} else if (arguments.pattern == "*") {
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