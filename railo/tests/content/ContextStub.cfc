component extends="craft.core.request.Context" {

	public void function init() {
		variables.extension = new craft.core.output.TXTExtension()
	}

	public Struct function render(required String view, required Struct model) {
		return {
			output: arguments.view,
			extension: variables.extension
		}
	}

}