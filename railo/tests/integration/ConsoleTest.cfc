component extends="mxunit.framework.TestCase" {

	public void function beforeTests() {

		var console = new stubs.ConsoleStub()
		var mapping = "/tests/integration/console"

		console.setCommandMapping(mapping & "/content/documents")
		console.addContentMapping("/craft/content")
		console.addContentMapping(mapping & "/elements")
		console.buildContent(mapping & "/content/includes")
		console.buildContent(mapping & "/content/layouts")
		console.registerElements("/craft/markup/library")
		console.registerElements(mapping & "/elements")
		console.addTemplateMapping(mapping & "/templates")
		console.addViewMapping(mapping & "/views")
		console.importRoutes(mapping & "/console.routes")

		console.commit()

		this.console = console
		this.endpoint = console.getEndpoint()

	}

	public void function tearDown() {
		content type="text/html" reset="false";
	}

	public void function Component() {
		var output = testRequest("GET", "/component.xml")

		assertTrue(IsXML(output))

		var result = XMLParse(output)

		var menuElement = '<menu><button label="New" /><button label="Open" /><button label="Close" /></menu>'
		var toolbarElement = '<menu><button label="Edit" /><button label="Copy" /><button label="Paste" /></menu>'
		var expected = XMLParse('<row><column span="1"><logo /></column><column span="1">#menuElement#</column><column span="1">#toolbarElement#</column></row>')

		assertEquals(expected, result)
	}

	public void function Document() {
		var output = testRequest("GET", "/document.xml")
		// The output is not yet valid xml because it contains 2 root elements.
		output = "<root>" & output & "</root>"

		assertTrue(IsXML(output))

		var result = XMLParse(output)

		var menuElement = '<menu><button label="New" /><button label="Open" /><button label="Close" /></menu>'
		var toolbarElement = '<menu><button label="Edit" /><button label="Copy" /><button label="Paste" /></menu>'
		var rowElement1 = '<row><column span="1"><logo /></column><column span="1">#menuElement#</column><column span="1">#toolbarElement#</column></row>'
		var contentElement = '<button label="Previous" /><button label="Next" />'
		var rowElement2 = '<row><column span="1"></column><column span="2">#contentElement#</column></row>'

		var expected = XMLParse("<root>" & rowElement1 & rowElement2 & "</root>")

		assertEquals(expected, result)
	}

	private String function testRequest(required String method, required String path, Struct parameters) {

		this.endpoint.setTestRequestMethod(arguments.method)
		this.endpoint.setTestPath(arguments.path)

		var parameters = arguments.parameters ?: null
		if (parameters !== null) {
			this.endpoint.setTestParameters(parameters)
		}

		savecontent variable="local.output" {
			this.console.handleRequest()
		}

		return Trim(output)
	}

}