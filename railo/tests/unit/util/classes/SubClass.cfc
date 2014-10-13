component extends="BaseClass" accessors="true" {

	property String property3;

	public void function init(required String property3) {
		this.property3 = arguments.property3
	}

	// Override publicMethod, make it private.
	private void function publicMethod() {}

	// Add methods with different access levels.
	public void function anotherPublicMethod() {}
	package void function packageMethod() {}
	remote void function remoteMethod() {}

}