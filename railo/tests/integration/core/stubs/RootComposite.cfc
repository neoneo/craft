component extends="craft.core.content.Composite" accessors="true" {

	property String constant;

	public Struct function model(required Context context, required Struct parentModel) {
		return {
			component: "root",
			depth: 1, // This variable will be incremented with each level in the hierarchy.
			constant: getConstant() // This exact instance should be passed down the hierarchy unchanged.
		}
	}

	public String function view(required Context context) {
		return "modelcomposite"
	}

}