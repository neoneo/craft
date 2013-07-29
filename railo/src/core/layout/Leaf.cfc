/**
 * @abstract
 **/
component extends="Node" {

	public String function render(required Context context, Struct parentModel) {

		var model = model(arguments.context, arguments.parentModel ?: {})
		var result = arguments.context.render(view(arguments.context), model)

		return result.output
	}

}