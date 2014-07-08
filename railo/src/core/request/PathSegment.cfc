import craft.core.content.Content;

import craft.core.util.ScopeCollection;

/**
 * PathSegment
 */
component {

	public void function init(required PathMatcher pathMatcher, String parameterName) {

		variables._pathMatcher = arguments.pathMatcher
		variables._parameterName = arguments.parameterName ?: null

		variables._content = {}
		variables._children = new ScopeCollection(this)

		variables._parent = null

	}

	/**
	 * Sets the content for the given content type.
	 */
	public void function setContent(required String type, required Content content) {
		variables._content[arguments.type] = arguments.content
	}

	public Content function content(required String type) {

		var item = variables._content[arguments.type] ?: null
		if (item === null) {
			Throw("No content of type #arguments.type# found", "NoSuchElementException")
		}

		return item
	}

	public Any function parameterName() {
		return variables._parameterName
	}

	public Numeric function match(required Array path) {
		return variables._pathMatcher.match(arguments.path)
	}

	public PathSegment[] function children() {
		return variables._children.toArray()
	}

	public void function addChild(required PathSegment child, PathSegment beforeChild) {
		// TODO: implement check for duplicates
		variables._children.add(argumentCollection: ArrayToStruct(arguments))
	}

	public Boolean function removeChild(required PathSegment child) {
		return variables._children.remove(arguments.child)
	}

	public Boolean function hasParent() {
		return variables._parent !== null
	}

	public PathSegment function parent() {
		return variables._parent
	}

	public void function setParent(required PathSegment parent) {
		variables._parent = arguments.parent
	}

}