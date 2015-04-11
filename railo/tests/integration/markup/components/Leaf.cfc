component extends="craft.content.Leaf" accessors = true {

	property String ref;

	public void function init(required String ref) {
		this.ref = arguments.ref
	}

	public Struct function process(required Context context) {
		return {
			ref: this.ref
		}
	}

	public String function view(required Context context) {
		return "leaf"
	}

}