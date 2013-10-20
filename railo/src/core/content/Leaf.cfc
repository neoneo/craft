/**
 * @abstract
 **/
component extends="Node" {

	public String function render(required Renderer renderer, required Struct baseModel) {
		return arguments.renderer.leaf(this, arguments.baseModel)
	}

	public Boolean function hasChildren() {
		return false
	}

}