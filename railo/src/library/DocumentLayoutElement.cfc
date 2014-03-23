import craft.core.content.DocumentLayout;

component extends="AbstractDocumentElement" accessors="true" tag="documentlayout" {

	property String extends;

	private String function layoutRef() {
		return getExtends()
	}

	private Document function createDocument(required LayoutContent layoutContent) {
		return new DocumentLayout(arguments.layoutContent)
	}

}