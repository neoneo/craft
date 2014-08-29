component implements="TemplateRenderer" {

	public String function render(required String template, required Struct model) {

		/*
			Append the model on the local scope for immediate availability in the included template.
			Using an include instead of a module performs a little better.
			In the template, care should be taken to scope all variables.
		*/
		StructAppend(local, arguments.model)

		savecontent variable="local.output" {
			include template="#arguments.template#";
		}

		return output;
	}

}