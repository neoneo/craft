component implements="Transformer" {

	public void function init(String delimiter = ",") {
		variables.delimiter = arguments.delimiter
	}

	public any function transform(required String value) {
		return ListToArray(arguments.value, variables.delimiter)
	}

}