import craft.util.ScopeCollection;

/**
 * PathSegment
 *
 * @abstract
 */
component {

	public void function init(String pattern = null, String parameterName = null) {

		variables._pattern = arguments.pattern
		variables._parameterName = arguments.parameterName

		variables._children = new ScopeCollection()
		variables._parent = null

		variables._commands = {} // Map of http methods to commands.

	}

	/**
	 * Sets the command to execute.
	 */
	public void function setCommand(required Command command, required String method) {
		variables._commands[arguments.method] = arguments.command
	}

	public Command function command(required String method) {

		if (!variables._commands.keyExists(arguments.method)) {
			Throw("Command not found", "NoSuchElementException")
		}

		return variables._commands[arguments.method]
	}

	public String function pattern() {
		return variables._pattern
	}

	public String function parameterName() {
		return variables._parameterName
	}

	/**
	 * Returns the number of segments in the given path that are matched by this `PathSegment`.
	 */
	public Numeric function match(required String[] path) {
		abort showerror="Not implemented";
	}

	public PathSegment[] function children() {
		return variables._children.toArray()
	}

	public void function addChild(required PathSegment child, PathSegment beforeChild) {
		// TODO: implement check for duplicates
		variables._children.add(argumentCollection: ArrayToStruct(arguments))
		arguments.child.setParent(this)
	}

	public Boolean function removeChild(required PathSegment child) {

		var success = variables._children.remove(arguments.child)
		if (success) {
			arguments.child.setParent(null)
		}

		return success
	}

	public Boolean function hasParent() {
		return variables._parent !== null
	}

	public PathSegment function parent() {
		return variables._parent
	}

	public void function setParent(required Any parent) {
		variables._parent = arguments.parent
	}

}