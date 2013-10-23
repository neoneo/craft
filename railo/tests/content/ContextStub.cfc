component extends="craft.core.request.Context" {

	public void function init() {
		variables.contentType = new craft.core.output.TXTContentType()
	}

}