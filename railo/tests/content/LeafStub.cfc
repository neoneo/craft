component extends="craft.core.content.Leaf" {

	private Struct function model(required Context context, Struct parentModel) {
		return {
			leaf: true,
			parent: arguments.parentModel ?: {}
		}
	}

	private String function view(required Context context) {
		return "leaf"
	}

}