component extends="craft.core.content.Composite" accessors="true" {

	property String name;

	public void function init(required String name) {
		setName(arguments.name)
	}

	public Struct function model(required Context context, required Struct parentModel) {
		return {
			node: getName()
		}
	}

	public String function view(required Context context) {
		return "composite"
	}

}