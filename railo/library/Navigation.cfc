import craft.util.Collection;

component accessors="true" {

	property String title;
	property Navigation parent;
	property PathSegment pathSegment; // cannot be null

	variables.children = new Collection(GetMetaData(this).name, this);

	public Array function getChildren() {
		return variables.children.toArray();
	}

	public Navigation function addChild(required Navigation navigation, Navigation beforeNavigation) {

		variables.children.add(argumentCollection: ArrayToStruct(arguments));

		return this;
	}

	public Navigation function removeChild(required Navigation navigation) {

		variables.children.remove(arguments.navigation);

		return this;
	}

	public Navigation function moveChild(required Navigation navigation, Navigation beforeNavigation) {

		variables.children.move(argumentCollection: ArrayToStruct(arguments));

		return this;
	}

	public Boolean function hasChild(required Navigation navigation) {
		return variables.children.contains(arguments.navigation);
	}

	public Boolean function hasChildren() {
		return !variables.children.isEmpty();
	}

	public String function getRequestPath(required Struct parameters) {
		return getPathSegment().getRequestPath(arguments.parameters);
	}

}