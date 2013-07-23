component {

	public Boolean function onEndTag(required Struct attributes, required Struct caller, required String generatedContent) {

		var inHead = arguments.attributes.keyExists("head") ? arguments.attributes.head : true;
		//arguments.caller.context.appendHTML(arguments.generatedContent, inHead);

		return false;
	}

}