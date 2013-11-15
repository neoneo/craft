component extends="DocumentElement" tag="document" {

	property String template;

	private String function templateRef() {
		return getTemplate()
	}

	private Document function createDocument(required TemplateContent templateContent) {
		return new Document(arguments.templateContent)
	}

}