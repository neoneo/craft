import craft.markup.*;

component extends="ChildElement" accessors="true" {

	property Element until; // Another element that has to finish construction first.

	public void function build(required Scope scope) {
		if (getUntil().ready()) {
			super.build(arguments.reader)
		}
	}

}