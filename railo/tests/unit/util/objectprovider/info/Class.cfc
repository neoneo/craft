/**
 * @transient
 */
component accessors = true {

	property String property1;
	property Numeric property2 required = true;
	property Date property3 setter = false;

	public void function init(required Numeric argument1, String argument2) {

	}

}