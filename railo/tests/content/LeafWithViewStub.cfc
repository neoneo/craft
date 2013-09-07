component extends="craft.core.content.Leaf" {

	public void function init(required String viewOutput) {
		super.init()
		variables.viewOutput = arguments.viewOutput
	}

	private String function view(required Context context) {
		return variables.viewOutput
	}

}