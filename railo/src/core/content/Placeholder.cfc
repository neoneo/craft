component extends="Node" accessors="true" {

	property String ref setter="false";

	public void function init(required String ref) {
		super.init()
		variables.ref = arguments.ref
	}

	public String function accept(required Renderer renderer, Struct baseModel) {
		return arguments.renderer.visitPlaceholder(this, arguments.baseModel)
	}

	public String function view(required Context context) {
		return ""
	}

}