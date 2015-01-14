component extends="craft.output.View" {

	public Any function render(required Any model) {
		return {
			ref: arguments.model.ref
		}
	}

}