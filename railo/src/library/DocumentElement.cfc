component extends="AbstractDocumentElement" accessors="true" tag="document" {

	property String template;

	private String function templateRef() {
		return getTemplate()
	}

	private Document function createDocument(required TemplateContent templateContent) {
		return new Document(arguments.templateContent)
	}

}