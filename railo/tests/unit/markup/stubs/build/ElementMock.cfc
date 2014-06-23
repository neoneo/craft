import craft.markup.*;

component extends="Element" {

	variables._ready = false

	public void function build(required Scope scope) {
		variables._ready = !hasChildren() || childrenReady()
		dump([getRef(), _ready])
	}

	public Boolean function ready() {
		return variables._ready
	}

}