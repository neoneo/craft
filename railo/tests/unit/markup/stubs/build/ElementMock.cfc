import craft.markup.*;

component extends="Element" {

	this.constructed = false

	public void function construct(required Scope scope) {
		this.constructed = getChildrenReady()
	}

	public Boolean function getReady() {
		return this.constructed;
	}

}