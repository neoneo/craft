component extends="craft.library.node.Container" accessors="true" {

	property Boolean fluid;

	public void function init() {
		setFluid(false);
		super.init()
	}

	public ScaffoldElement function setFluid(required Boolean fluid) {

		var className = getClassName()
		removeClass(className)
		removeClass(className & "-fluid")
		addClass(className & (arguments.fluid ? "-fluid" : ""))

		return this;
	}

	/**
	 * Returns the base class name used by Bootstrap.
	 **/
	private String function getClassName() {
		Throw("Function #GetFunctionCalledName()# must be implemented", "NotImplementedException")
	}

}