import craft.core.layout.Context;

import craft.core.util.Branch;

/**
 * Base class for the composite pattern.
 * @abstract
 **/
component implements="Branch" {

	public void function init() {}

	public String function render(required Context context, Struct parentModel) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

	public Boolean function hasParent() {
		return StructKeyExists(variables, "parent")
	}

	public Component function getParent() {
		return variables.parent
	}

	public void function setParent(required Component parent) {
		variables.parent = arguments.parent
	}

	public Boolean function hasChildren() {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

	/**
	 * Collects data pertaining to the view before rendering.
	 **/
	private Struct function model(required Context context, Struct parentModel) {
		return IsNull(arguments.parentModel) ? {} : arguments.parentModel
	}

	private String function view(required Context context) {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

}