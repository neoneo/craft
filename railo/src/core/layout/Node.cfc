import craft.core.layout.Context
import craft.core.util.Branch

/**
 * Base class for the composite pattern.
 * @abstract
 **/
component implements="Content,Branch" {

	public void function init() {}

	public String function render(required Context context) {
		return result(arguments.context).output
	}

	public Boolean function hasParent() {
		return StructKeyExists(variables, "parent")
	}

	public Composite function getParent() {
		return variables.parent
	}

	public void function setParent(required Composite parent) {
		variables.parent = arguments.parent
	}

	public Boolean function hasChildren() {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

	public Array function getChildren() {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

	public void function addChild(required Node child, Node beforeChild) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

	public void function removeChild(required Node child) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

	/**
	 * Collects data pertaining to the view before rendering.
	 **/
	private Struct function model(required Context context) {
		return {}
	}

	private Struct function result(required Context context) {
		return arguments.context.render(view(arguments.context), model(arguments.context))
	}

	private String function view(required Context context) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

}