/**
 * This class will get values injected.
 *
 * @transient
 */
component accessors = true {

	property String property1;
	property Numeric property2 required = true;
	property Date property3 setter = false;

	property Array values setter = false;

	public void function init(required Numeric argument1, String argument2) {
		this.values = [arguments.argument1, arguments.argument2]
	}

}