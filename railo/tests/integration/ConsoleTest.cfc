component extends="mxunit.framework.TestCase" {

	public void function beforeTests() {

		var console = new stubs.ConsoleStub()
		var mapping = "/crafttests/integration/console"

		console.setContentMapping(mapping & "/content/documents")
		console.buildContent(mapping & "/content/includes")
		console.buildContent(mapping & "/content/layouts")
		console.registerElements("/craft/markup/library")
		console.registerElements(mapping & "/elements")
		console.addTemplateMapping(mapping & "/templates")
		console.setTemplateExtension("cfm")
		console.addViewMapping(mapping & "/views")
		console.importRoutes(mapping & "/console.routes")

		console.commit()

		variables.console = console
		variables.endPoint = console.endPoint()

	}

	// public void function Component() {
	// 	var result = testRequest("GET", "/component.xml")

	// 	assertTrue(IsXML(result))
	// }

	public void function Document() {
		var result = testRequest("GET", "/document.xml")

		echo(result)
		abort;
	}

	private String function testRequest(required String method, required String path, Struct parameters) {

		variables.endPoint.setTestRequestMethod(arguments.method)
		variables.endPoint.setTestPath(arguments.path)

		var parameters = arguments.parameters ?: null
		if (parameters !== null) {
			variables.endPoint.setTestParameters(parameters)
		}

		savecontent variable="local.output" {
			variables.console.handleRequest()
		}

		return Trim(output)
	}

}