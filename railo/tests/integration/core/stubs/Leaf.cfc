component extends="craft.core.content.Leaf" accessors="true" {

	property String name;

	public void function init(required String name) {
		setName(arguments.name)
	}

	public Struct function model(required Context context, required Struct parentModel) {
		return {
			component: getName()
		}
	}

	public String function view(required Context context) {
		return "leaf"
	}

}