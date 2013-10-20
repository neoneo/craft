component extends="craft.core.content.Node" {

	public String function render(required Context context, Struct baseModel) {

		var model = model(arguments.context, arguments.baseModel ?: {})
		var result = arguments.context.render(view(arguments.context), model)

		return result.output
	}

	private String function view(required Context context) {
		return "node"
	}

}