component implements="Transformer" {

	public any function transform(required String value) {
		return IsValid("Boolean", arguments.value) ? (YesNoFormat(arguments.value) ? true : false) : Len(arguments.value) > 0
	}

}