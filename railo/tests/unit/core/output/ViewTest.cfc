import craft.core.output.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		variables.view = new View()
		variables.model = {}
	}

	public void function Get_Should_ThrowUnsupportedOperationException_When_Undefined() {
		try {
			variables.view.get(model)
		} catch (UnsupportedOperationException e) {}
	}

	public void function Post_Should_ThrowUnsupportedOperationException_When_Undefined() {
		try {
			variables.view.post(model)
		} catch (UnsupportedOperationException e) {}
	}

	public void function Put_Should_ThrowUnsupportedOperationException_When_Undefined() {
		try {
			variables.view.put(model)
		} catch (UnsupportedOperationException e) {}
	}

	public void function Delete_Should_ThrowUnsupportedOperationException_When_Undefined() {
		try {
			variables.view.delete(model)
		} catch (UnsupportedOperationException e) {}
	}

	public void function Patch_Should_ThrowUnsupportedOperationException_When_Undefined() {
		try {
			variables.view.patch(model)
		} catch (UnsupportedOperationException e) {}
	}

	public void function Render_Should_CallCorrectMethod() {
		var view = new ViewStub()
		var model = {}

		var get = view.render(model, "get")
		var post = view.render(model, "post")
		var put = view.render(model, "put")
		var delete = view.render(model, "delete")
		var patch = view.render(model, "patch")

		assertEquals("get", get)
		assertEquals("post", post)
		assertEquals("put", put)
		assertEquals("delete", delete)
		assertEquals("patch", patch)
	}

}