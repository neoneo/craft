component implements="craft.core.util.Branch" accessors="true" {

	property String id;

	public void function init() {
		variables.id = CreateUniqueId()
	}

	public Boolean function hasParent() {
		return StructKeyExists(variables, "parent")
	}

	public Branch function getParent() {
		return variables.parent
	}

	public void function setParent(required Branch parent) {
		variables.parent = arguments.parent
	}
	// public Boolean function hasChildren();
	// public Array function getChildren();
	// public void function addChild(required Branch child, Branch beforeChild);
	// public void function removeChild(required Branch child);

}