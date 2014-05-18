import craft.core.content.Content;

import craft.core.util.ScopeCollection;

/**
 * PathSegment
 */
component {

	public void function init(required PathMatcher pathMatcher, String parameterName) {

		variables._pathMatcher = arguments.pathMatcher
		variables._parameterName = arguments.parameterName ?: NullValue()

		variables._content = {}
		variables._children = new ScopeCollection(this)

	}

	/**
	 * Sets the content for the given content type.
	 */
	public void function setContent(required String type, required Content content) {
		variables._content[arguments.type] = arguments.content
	}

	public Content function content(required String type) {

		var content = variables._content[arguments.type] ?: NullValue()
		if (IsNull(content)) {
			Throw("No content of type #arguments.type# found", "ContentNotFoundException")
		}

		return content
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
		return !IsNull(variables._parent)
	}

	public PathSegment function parent() {
		return variables._parent
	}

	public void function setParent(required PathSegment parent) {
		variables._parent = arguments.parent
	}

}