component extends="TemplateComponent" implements="TemplateContent" {

	/**
	 * @override Node
	 */
	private Struct function result(required Context context) {
		return {
			output = "[[children]]", // the template should only gather all contents of its children
			extension = arguments.context.getExtenstion()
		}
	}

}