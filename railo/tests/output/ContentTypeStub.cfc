component extends="craft.core.output.ContentType" {

	property String name;

	public void function init(required String name) {
		variables.name = arguments.name
		super.init()
	}

	public String function getName() {
		return variables.name
	}

}