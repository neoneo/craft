import craft.core.layout.Content
import craft.core.util.Branch
import craft.core.util.BranchList

/**
 * PathSegment
 **/
component implements="Branch" accessors="true" {

	property String parameterName setter="false"; // the name of the parameter that corresponds to this path segment

	public void function init(required PathMatcher pathMatcher, required BranchList branchList, String parameterName) {

		variables.pathMatcher = arguments.pathMatcher
		variables.children = arguments.branchList
		variables.parameterName = arguments.parameterName ?: null

		variables.content = {}

	}

	/**
	 * Sets the content for the given content type.
	 **/
	public void function setContent(required String type, required Content content) {
		variables.content[arguments.type] = arguments.content
	}

	public Content function getContent(required String type) {

		var content = variables.content[arguments.type] ?: null
		if (content == null) {
			Throw("No content of type #arguments.type# found", "ContentNotFoundException")
		}

		return content
	}

	public Numeric function match(required Array path) {
		return variables.pathMatcher.match(arguments.path)
	}

	// Branch IMPLEMENTATION ======================================================================

	public Array function getChildren() {
		return variables.children.toArray()
	}

	public void function addChild(required PathSegment child, PathSegment beforeChild) {
		// TODO: implement check for duplicates
		variables.children.add(argumentCollection = arguments.toStruct())
	}

	public void function removeChild(required PathSegment child) {
		variables.children.remove(arguments.child)
	}

	public Boolean function hasParent() {
		return StructKeyExists(variables, "parent")
	}

	public PathSegment function getParent() {
		return variables.parent
	}

	public void function setParent(required PathSegment parent) {
		variables.parent = arguments.parent
	}

}