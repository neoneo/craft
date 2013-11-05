component extends="craft.core.content.Composite" accessors="true" {

	property String name;

	public void function init(required String name) {
		super.init()
		setName(arguments.name)
	}

	public Struct function model(required Context context, required Struct parentModel) {
		var depth = arguments.parentModel.keyExists("depth") ? arguments.parentModel.depth + 1 : 1;

		return {
			node: getName(),
			depth: depth
		}
	}

	public String function view(required Context context) {
		return "modelcomposite"
	}

}