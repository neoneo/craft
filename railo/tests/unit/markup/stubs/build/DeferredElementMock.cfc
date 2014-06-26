import craft.markup.*;

component extends="ElementMock" accessors="true" {

	property Element until; // Another element that has to finish construction first.

	public void function construct(required Scope scope) {
		if (getUntil().ready()) {
			super.construct(arguments.scope)
		}
	}

}