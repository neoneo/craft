component {

	public void function init(required PathSegment root, required PathSegmentFactory pathSegmentFactory, required CommandFactory commandFactory) {
		this.root = arguments.root
		this.pathSegmentFactory = arguments.pathSegmentFactory
		this.commandFactory = arguments.commandFactory

		// Array of path segments that correspond to the indents in the routes file.
		this.indentLevels = []
		this.commands = {}
	}

	/**
	 * Reads the routes file located at the given path, and creates / amends `PathSegment`s.
	 */
	public void function import(required String path) {

		this.indentLevels.clear()
		FileRead(arguments.path).listToArray(Chr(10)).each(function (route) {
			// Strip off comments.
			var route = Trim(arguments.route.reReplace("##.*$", ""))
			if (!route.isEmpty()) {
				parse(route)
			}
		})

	}

	/**
	 * Reads the routes file located at the given path, and removes the corresponding `Command`s.
	 */
	public void function purge(required String path) {

		this.indentLevels.clear()
		FileRead(arguments.path).listToArray(Chr(10)).each(function (route) {
			var route = Trim(arguments.route.reReplace("##.*$", ""))
			if (!route.isEmpty()) {
				remove(route)
			}
		})

		this.root.trim()

	}

	/**
	 * Splits the route into its parts and returns them in a struct with keys:
	 * - method: the http method
	 * - pathSegment: the existing `PathSegment` to which any indents lead
	 * - path: the path relative to this `PathSegment`
	 * - identifier: the `Command` identifier
	 */
	private Struct function tokenizeRoute(required String route, required Boolean requireIdentifier) {
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
			if (this.indentLevels.isEmpty()) {
				Throw("Route '.' cannot be the first route", "NoSuchElementException");
			}
			pathSegment = this.indentLevels.last()
			path = ""
		} else if (path.startsWith(">")) {
			var level = path.len()
			pathSegment = pick(this.indentLevels, level)

			index += 1
			path = pick(words, index)

			// If the indent level decreased, remove everything after the current level.
			if (level < this.indentLevels.len()) {
				this.indentLevels = this.indentLevels.slice(1, level)
			}

		} else {
			// No indents.
			pathSegment = this.root
			this.indentLevels.clear()
		}

		// The command identifier.
		if (arguments.requireIdentifier) {
			index += 1
			var identifier = pick(words, index)
		}

		return {
			method: method,
			path: path,
			identifier: identifier ?: null,
			pathSegment: pathSegment
		};
	}

	private Struct function tokenizeSegment(required String segment) {

		if (arguments.segment.startsWith("@")) {
			return {
				pattern: ".*",
				parameterName: arguments.segment.removeChars(1, 1)
			}
		} else if (arguments.segment contains "@") {
			// Split the segment at any @ sign that is not escaped by a \, unless that \ is itself escaped.
			// This uses a Java regex, which supports negative lookbehind.
			var parts = arguments.segment.split("(?<!(?<!\\)\\)@")
			// We accept 1 or 2 parts. It's a Java array so we can't use member functions.
			if (ArrayLen(parts) > 2) {
				Throw("Invalid path segment '#arguments.segment#'", "IllegalArgumentException", "Escape @ signs with a \ where applicable");
			}

			return {
				pattern: parts[1].reReplace("\\([@\\])", "\1", "all"),
				parameterName: ArrayLen(parts) == 2 ? parts[2] : null
			};
		} else {
			return {
				pattern: arguments.segment,
				parameterName: null
			};
		}
	}

	/**
	 * Parses a single route and returns the corresponding `PathSegment`.
	 */
	public PathSegment function parse(required String route) {

		var tokens = tokenizeRoute(arguments.route, true) // true: require identifier.

		// Split the path into segments, start at the path segment returned by tokenizeRoute().
		var pathSegment = tokens.path.listToArray("/").reduce(function (pathSegment, segment) {
			// Parse the segment for a parameter name.
			var tokens = tokenizeSegment(arguments.segment)
			var pattern = tokens.pattern

			// Try to find a path segment that has this pattern.
			var children = arguments.pathSegment.children
			var index = children.find(function (child) {
				return arguments.child.pattern == pattern;
			})
			if (index > 0) {
				// Found it: continue with this path segment.
				return children[index];
			} else {
				// There is no path segment for this pattern, so create it.
				var child = this.pathSegmentFactory.create(pattern, tokens.parameterName)
				arguments.pathSegment.addChild(child)
				// Continue with the child for the next iteration.
				return child;
			}
		}, tokens.pathSegment)

		// The pathSegment variable now contains the path segment that corresponds to the route.
		// Push the path segment on the indent levels in case the next parse uses indents.
		this.indentLevels.append(pathSegment)

		if (!this.commands.keyExists(tokens.identifier)) {
			this.commands[tokens.identifier] = this.commandFactory.create(tokens.identifier)
		}
		pathSegment.setCommand(this.commands[tokens.identifier], tokens.method)

		return pathSegment;
	}

	/**
	 * Removes the `Command` for the route.
	 */
	public void function remove(required String route) {

		var route = arguments.route
		var tokens = tokenizeRoute(route, false) // false: identifier not required.
		var path = tokens.path
		// Walk the path starting at the path segment. Path segments for the complete path are expected to exist.
		var pathSegment = path.listToArray("/").reduce(function (pathSegment, segment) {

			var tokens = tokenizeSegment(arguments.segment)
			var pattern = tokens.pattern

			var children = arguments.pathSegment.children
			var index = children.find(function (child) {
				return arguments.child.pattern == pattern;
			})
			if (index == 0) {
				Throw("Route '#path#' not found", "NoSuchElementException");
			}

			return children[index];
		}, tokens.pathSegment)

		// Remove the command.
		pathSegment.removeCommand(tokens.method)

	}

	private Any function pick(required Array array, required Numeric index) {
		if (arguments.array.len() < arguments.index) {
			Throw("Number of items does not match", "NoSuchElementException", "Expected #arguments.index# but found #arguments.array.len()#");
		}

		return arguments.array[arguments.index];
	}

}