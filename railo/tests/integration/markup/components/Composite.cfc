component extends="craft.content.Composite" accessors="true" {

	property String ref;

	public void function init(required String ref) {
		setRef(arguments.ref)
	}

	public Struct function process(required Context context) {
		return {
			component: getRef()
		}
	}

	public Any function view(required Context context) {
		return this.getViewFactory().create("composite")
	}

}