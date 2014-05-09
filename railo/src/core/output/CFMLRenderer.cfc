component implements="TemplateRenderer" {

	public void function init(required TemplateFinder templateFinder) {
		variables._templateFinder = arguments.templateFinder
	}

	public String function render(required String template, required Struct model) {

		var template = variables._templateFinder.get(arguments.template)

		/*
			Append the model on the local scope for immediate availability in the included template.
			Using an include instead of a module performs a little better.
			In the template, care should be taken to scope all variables, or alternatively local scope mode could be set to modern in the admin.
		*/
		StructAppend(local, arguments.model)

		savecontent variable="local.output" {
			include template="#template#";
		}

		return output
	}

}