/**
 * This class will get class instances injected.
 *
 * @transient
 */
component accessors = true {

	property InjectValues injectValues;

	property Empty empty setter = false;

	public void function init(required Empty empty) {
		this.empty = arguments.empty
	}

}