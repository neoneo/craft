import craft.markup.*;

component extends="Element" {

	variables._ready = false

	public void function construct(required Scope scope) {
		variables._ready = !hasChildren() || childrenReady()
	}

	public Boolean function ready() {
		return variables._ready
	}

}