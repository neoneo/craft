import craft.output.TemplateView;

component extends="tests.MocktorySpec" {

	function run() {

		describe("TemplateRenderer", function () {

			beforeEach(function () {
				template = "template"
				model = {key: 1}

				templateRenderer = mock("TemplateRenderer")
			})

			describe(".render", function () {

				it("should forward the call to the template renderer and return the result", function () {
					mock({
						$object: templateRenderer,
						render: {
							$args: [template, model],
							$returns: "result",
							$times: 1
						}
					})

					var view = new TemplateView(template)
					view.templateRenderer = templateRenderer

					expect(view.render(model)).toBe("result")

					verify(templateRenderer)
				})

				it("should pass the given properties to the template", function () {
					var properties = {
						property1: "one",
						property2: "two",
						property3: "three"
					}
					// The model being rendered is the model and the properties combined.
					var renderedModel = Duplicate(model, false).append(properties)
					mock({
						$object: templateRenderer,
						render: {
							$args: [template, renderedModel],
							$returns: "result",
							$times: 1
						}
					})

					var view = new TemplateView(template, properties)
					view.templateRenderer = templateRenderer

					// The view receives the model without the properties.
					expect(view.render(model)).toBe("result")

					verify(templateRenderer)
				})

			})

		})
	}

}