component implements="Renderer" {

	public void function init(required ViewInventory viewInventory) {
		variables.viewInventory = arguments.viewInventory
	}

	public Struct function render(required String view, required Struct model, required Extension extension) {

		// the view inventory returns the name of the template and the extension that is rendered by the template
		var data = variables.viewInventory.get(arguments.view, arguments.extension)
		var template = data.template
		var extension = data.extension

		// append the model on the local scope for immediate availability in the included template
		// using an include instead of a module performs better
		// in the admin, local scope mode should be set to modern, or variables created by the template will be put on the variables scope
		local.append(arguments.model)

		savecontent variable="local.output" {
			include template="#arguments.template#"
		}

		return {
			output: output,
			extension: extension
		}
	}

}