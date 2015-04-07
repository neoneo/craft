// Railo dpesn't recognize a mocked _toString method.
component implements="craft.output.Stringifiable" {

	public void function init(required String result) {
		this.result = arguments.result
	}

	public String function _toString() {
		return this.result;
	}

}