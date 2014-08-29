import craft.content.Document;
import craft.content.LayoutContent;

component extends="AbstractDocumentElement" accessors="true" tag="document" {

	property String layout required="true";

	private String function getLayoutRef() {
		return this.layout;
	}

	private Document function createDocument(required LayoutContent layoutContent) {
		return new Document(arguments.layoutContent);
	}

}