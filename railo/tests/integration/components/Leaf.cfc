component extends="craft.core.content.Leaf" accessors="true" {

	property String ref;

	public void function init(required String ref) {
		setRef(arguments.ref)
	}

	public Struct function model(required Context context) {
		return {
			component: getRef()
		}
	}

	public String function view(required Context context) {
		return "leaf"
	}

}