component extends="craft.content.Composite" accessors = true {

	property String ref;

	private void function configure(required String ref) {
		setRef(arguments.ref)
	}

	public Struct function process(required Context context) {
		return {
			component: getRef()
		}
	}

	public View function view(required Context context) {
		return this.viewRepository.create("composite")
	}

}