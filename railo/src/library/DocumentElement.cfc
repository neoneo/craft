component extends="AbstractDocumentElement" accessors="true" tag="document" {

	property String layout;

	private String function layoutRef() {
		return getLayout()
	}

	private Document function createDocument(required LayoutContent layoutContent) {
		return new Document(arguments.layoutContent)
	}

}