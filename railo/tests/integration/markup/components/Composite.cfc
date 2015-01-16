component extends="craft.content.Composite" accessors="true" {

	property String ref;

	public void function init(required String ref) {
		this.ref = arguments.ref
	}

	public Struct function process(required Context context) {
		return {
			ref: this.ref
		}
	}

	public Any function view(required Context context) {
		return this.viewFactory.create("composite")
	}

}