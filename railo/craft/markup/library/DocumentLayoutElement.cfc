import craft.content.DocumentLayout;
import craft.content.LayoutContent;

component extends = AbstractDocumentElement accessors = true tag = documentlayout {

	property String extends required = true;

	private String function getLayoutRef() {
		return this.extends;
	}

	private Document function createDocument(required LayoutContent layoutContent) {
		return new DocumentLayout(arguments.layoutContent);
	}

}