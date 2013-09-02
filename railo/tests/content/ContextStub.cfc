component extends="craft.core.request.Context" {

	public void function init() {}

	public Struct function render(required String view, required Struct model) {
		var output = {
			view: arguments.view,
			model: arguments.model
		}
		return {
			output: SerializeJSON(output)
		}
	}

}