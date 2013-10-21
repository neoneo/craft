component extends="craft.core.request.Context" {

	public void function init() {
		variables.contentType = new craft.core.output.TXTContentType()
	}

	public Struct function render(required String view, required Struct model) {
		return {
			output: arguments.view,
			contentType: variables.contentType
		}
	}

}