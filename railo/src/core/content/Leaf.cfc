/**
 * @abstract
 **/
component extends="Node" {

	public String function accept(required Renderer renderer, required Struct baseModel) {
		return arguments.renderer.visitLeaf(this, arguments.baseModel)
	}

	public Boolean function hasChildren() {
		return false
	}

}