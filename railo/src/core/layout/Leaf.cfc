/**
 * @abstract
 **/
component extends="Node" {

	public Boolean function hasChildren() {
		return false
	}

	public Array function getChildren() {
		Throw("Not supported")
	}

	public void function addChild(required Node child, Node beforeChild) {
		Throw("Not supported")
	}

	public void function removeChild(required Node child) {
		Throw("Not supported")
	}

}