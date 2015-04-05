component extends = TemplateRenderer {

	public void function init() {
		super.init("cfm")
	}

	public String function render(required String template, required Struct model) {

		var mapping = this.templateFinder.get(arguments.template)

		/*
			Append the model on the local scope for immediate availability in the included template.
			Using an include instead of a module performs a little better.
			In the template, care should be taken to scope all variables.
		*/
		local.append(arguments.model)

		savecontent variable = local.output {
			include template = mapping;
		}

		return output;
	}

}