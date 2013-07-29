import craft.core.layout.Context;
import craft.core.util.Branch;

/**
 * Base class for the composite pattern.
 * @abstract
 **/
component implements="Branch" {

	public void function init() {}

	public String function render(required Context context) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
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

	/**
	 * Collects data pertaining to the view before rendering.
	 **/
	private Struct function model(required Context context) {
		return {}
	}

	private String function view(required Context context) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

}