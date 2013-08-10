component implements="Renderer" {

	public void function init(required ViewFinder viewFinder) {
		variables.viewFinder = arguments.viewFinder
	}

	public Struct function render(required String view, required Struct model, required String requestMethod, required Extension extension) {

		// the view inventory returns the name of the template and the extension that is rendered by the template
		var data = variables.viewFinder.get(arguments.view, arguments.requestMethod, arguments.extension)
		var template = data.template
		var extension = data.extension

		// append the model on the local scope for immediate availability in the included template
		// using an include instead of a module performs better
		// in the admin, local scope mode should be set to modern, or variables created by the template will be put on the variables scope
		StructAppend(local, arguments.model)

		savecontent variable="local.output" {
			include template="#template#"
		}

		return {
			output: output,
			extension: extension
		}
	}

}