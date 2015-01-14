component extends="craft.content.Leaf" accessors="true" {

	property String ref;

	public void function init(required String ref) {
		setRef(arguments.ref)
	}

	public Struct function process(required Context context) {
		return {
			ref: getRef()
		}
	}

	public Any function view(required Context context) {
		return this.getViewFactory().create("leaf")
	}

}