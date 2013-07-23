component implements="Renderer" {

	public String function render(required String template, required Struct model) {

		// append the model on the local scope for immediate availability in the included template
		// using an include instead of a module performs better
		// in the admin, local scope mode should be set to modern, or variables created by the template will be put on the variables scope
		local.append(arguments.model)

		savecontent variable="local.output" {
			include template="#arguments.template#"
		}

		return output
	}

}