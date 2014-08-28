import craft.util.ScopeCollection;

/**
 * PathSegment
 *
 * @abstract
 */
component accessors="true" {

	property Array children setter="false"; // PathSegment[]
	property String pattern;
	property String parameterName;
	property PathSegment parent;

	public void function init(String pattern = null, String parameterName = null) {

		this.pattern = arguments.pattern
		this.parameterName = arguments.parameterName

		this.childCollection = new ScopeCollection()
		this.parent = null

		this.commands = {} // Map of http methods to commands.

	}

	/**
	 * Sets the command to execute.
	 */
	public void function setCommand(required Command command, required String method) {
		this.commands[arguments.method] = arguments.command
	}

	public Command function command(required String method) {

		if (!hasCommand(arguments.method)) {
			Throw("Command for method '#arguments.method#' not found", "NoSuchElementException");
		}

		return this.commands[arguments.method];
	}

	public void function removeCommand(required String method) {
		this.commands.delete(arguments.method)
	}

	public Boolean function hasCommand(String method = null) {
		return arguments.method === null ? !this.commands.isEmpty() : this.commands.keyExists(arguments.method);
	}

	/**
	 * Returns the number of segments in the given path that are matched by this `PathSegment`.
	 */
	public Numeric function match(required String[] path) {
		abort showerror="Not implemented";
	}

	public Boolean function hasChildren() {
		return !this.childCollection.isEmpty();
	}

	public PathSegment[] function getChildren() {
		return this.childCollection.toArray();
	}

	public void function addChild(required PathSegment child, PathSegment beforeChild) {
		// TODO: implement check for duplicates
		this.childCollection.add(argumentCollection: ArrayToStruct(arguments))
		arguments.child.setParent(this)
	}

	public Boolean function removeChild(required PathSegment child) {

		var success = this.childCollection.remove(arguments.child)
		if (success) {
			arguments.child.parent = null
		}

		return success;
	}

	public Boolean function hasParent() {
		return this.parent !== null;
	}

	/**
	 * Removes all descendants without `Command`s and child `PathSegment`s.
	 */
	public void function trim() {

		this.getChildren().reverse().each(function (child) {
			arguments.child.trim()
			if (!arguments.child.hasCommand() && !arguments.child.hasChildren()) {
				removeChild(arguments.child)
			}
		})

	}

}