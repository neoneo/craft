component implements="Transformer" {

	public void function init(templateRepository) {
		// we need a repository where to get the template instance from
		variables.templateRepository = arguments.templateRepository
	}

	public any function transform(required String value) {
		return variables.templateRepository.get(arguments.value)
	}

}