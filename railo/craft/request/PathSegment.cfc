import craft.util.Collection;
import craft.util.ScopeCollection;

/**
 * PathSegment
 *
 * @abstract
 */
component accessors = true {

	property Array children setter = false; // PathSegment[]
	property Boolean hasChildren setter = false;
	property Boolean hasParent setter = false;
	property String parameterName setter = false;
	property PathSegment parent;
	property String pattern setter = false;

	public void function init(String pattern = null, String parameterName = null) {

		this.pattern = arguments.pattern
		this.parameterName = arguments.parameterName

		this.childCollection = this.createCollection()
		this.parent = null

		this.commands = {} // Map of http methods to commands.

	}

	/**
	 * Sets the command to execute for the given HTTP method.
	 */
	public void function setCommand(required String method, required Command command) {
		this.commands[arguments.method] = arguments.command
	}

	public Command function command(required String method) {

		if (!this.hasCommand(arguments.method)) {
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

	public Boolean function getHasChildren() {
		return !this.childCollection.isEmpty();
	}

	public Array function getChildren() {
		return this.childCollection.toArray();
	}

	public Boolean function addChild(required PathSegment child, PathSegment beforeChild) {

		var success = this.childCollection.add(arguments.child, arguments.beforeChild ?: null)
		if (success) {
			arguments.child.parent = this
		}

		return success;
	}

	public Boolean function removeChild(required PathSegment child) {

		var success = this.childCollection.remove(arguments.child)
		if (success) {
			arguments.child.parent = null
		}

		return success;
	}

	public Boolean function moveChild(required Component child, Component beforeChild) {
		return this.childCollection.move(arguments.child, arguments.beforeChild ?: null);
	}

	public Boolean function getHasParent() {
		return this.parent !== null;
	}

	/**
	 * Removes all descendants without `Command`s and child `PathSegment`s.
	 */
	public void function trim() {

		for (var child in this.getChildren().reverse()) {
			child.trim()
			if (!child.hasCommand() && !child.getHasChildren()) {
				removeChild(child)
			}
		})

	}

	/**
	 * Traverses the path to find the target `PathSegment` corresponding to the path. Returns the pair `PathSegment` and parameters in a struct.
	 */
	public Struct function walk(required String[] path) {

		if (arguments.path.isEmpty()) {
			return {
				target: this,
				parameters: {}
			}
		} else {
			for (var child in this.getChildren()) {
				var count = child.match(arguments.path)
				if (count > 0) {
					// Remove the number of segments that were matched and walk the remaining path, starting at the child.
					var remainingPath = count == arguments.path.len() ? [] : arguments.path.slice(count + 1)
					var result = child.walk(remainingPath)

					if (result.target !== null) {
						// The complete path is traversed so the current path segment is part of the tree.
						var parameterName = child.parameterName
						if (parameterName !== null) {
							// Get the part of the path that was actually matched by the current path segment.
							result.parameters[parameterName] = arguments.path.slice(1, count).toList("/")
						}

						return result;
					}
				}
			}
		}

		return {target: null}
	}

	private Collection function createCollection() {
		return new ScopeCollection();
	}

}