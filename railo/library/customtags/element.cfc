component {

	public void function init(required Boolean hasEndTag) {
		variables.hasEndTag = arguments.hasEndTag
	}

	public Boolean function onStartTag(required Struct attributes, required Struct caller) {

		if (!variables.hasEndTag) {
			execute(arguments.attributes, arguments.caller)
		}

		return true
	}

	public Boolean function onEndTag(required Struct attributes, required Struct caller, required String generatedContent) {

		execute(arguments.attributes, arguments.caller, arguments.generatedContent)

		return false
	}

	private Boolean function inHead() {
		return true
	}

	private void function execute(required Struct attributes, required Struct caller, String generatedContent = "") {

		var nodeName = ListLast(GetMetaData(this).name, ".")
		var attributeList = ""
		arguments.attributes.each(function (attribute, value) {
			attributeList &= " " & arguments.attribute & "=" & Chr(34) & arguments.value & Chr(34)
		})

		var html = "<#nodeName##attributeList#>"
		if (variables.hasEndTag) {
			html &= arguments.generatedContent & "</#nodeName#>"
		}

		var page = arguments.caller.renderer.append("head", html) // of zoiets ??

		//arguments.caller.context.appendHTML(html, inHead());

	}

}