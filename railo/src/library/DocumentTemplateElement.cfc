import craft.core.content.DocumentTemplate;

component extends="AbstractDocumentElement" accessors="true" tag="documenttemplate" {

	property String extends;

	private String function templateRef() {
		return getExtends()
	}

	private Document function createDocument(required TemplateContent templateContent) {
		return new DocumentTemplate(arguments.templateContent)
	}

}