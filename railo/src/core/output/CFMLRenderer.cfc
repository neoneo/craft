component implements="Renderer" {

	public void function init(required ViewFinder viewFinder) {
		variables.viewFinder = arguments.viewFinder
	}

	public String function render(required String view, required Struct model, required ContentType contentType) {

		var template = variables.viewFinder.get(arguments.view, arguments.contentType)

		/*
			Append the model on the local scope for immediate availability in the included template.
			Using an include instead of a module performs a little better.
			In the view, care should be taken to scope all variables, or alternatively local scope mode could be set to modern in the admin.
		*/
		StructAppend(local, arguments.model)

		savecontent variable="local.output" {
			include template="#template#"
		}

		return output
	}

}