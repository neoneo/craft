component implements="Transformer" {

	public any function transform(required String value) {
		return ToString(arguments.value)
	}

}