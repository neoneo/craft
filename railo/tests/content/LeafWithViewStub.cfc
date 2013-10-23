component extends="craft.core.content.Leaf" {

	public void function init(required String viewOutput) {
		super.init()
		variables.viewOutput = arguments.viewOutput
	}

	public String function view(required Context context) {
		return variables.viewOutput
	}

}