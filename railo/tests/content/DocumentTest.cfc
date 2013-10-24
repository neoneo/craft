import craft.core.content.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		//var section = mock(new Section())
		variables.template = mock(CreateObject("Template"))
		variables.document = new Document(variables.template)
	}

	public void function Accept_Should_InvokeVistor() {
		var visitor = mock(new VisitorStub()).visitDocument(variables.document)
		variables.document.accept(visitor)

		visitor.verify().visitDocument(variables.document)
	}

}