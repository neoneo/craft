component extends="craft.core.content.Leaf" accessors="true" {

	property String name;

	public void function init(required String name) {
		super.init()
		setName(arguments.name)
	}

	public Struct function model(required Context context, required Struct parentModel) {
		return {
			node: getName(),
			depth: arguments.parentModel.depth + 1
		}
	}

	public String function view(required Context context) {
		return "modelleaf"
	}

}