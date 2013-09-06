component extends="LeafStub" {

	private String function view(required Context context) {
		return "leaf"
	}

	private Struct function model(required Context context, Struct parentModel = {}) {
		var model = {
			test: true
		}
		model.append(arguments.parentModel, false)

		return model
	}

}