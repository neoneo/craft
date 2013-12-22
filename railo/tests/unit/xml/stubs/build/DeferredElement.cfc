import craft.xml.*;

component extends="ChildElement" accessors="true" {

	property Element until; // Another element that has to finish construction first.

	public void function construct(required Reader reader) {
		if (getUntil().ready()) {
			super.construct(arguments.reader)
		}
	}

}