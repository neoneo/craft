import craft.output.TemplateView;

component extends="tests.MocktorySpec" {

	function run() {

		describe("TemplateView", function () {

			beforeEach(function () {
				template = "template"
				model = {key: 1}

				templateRenderer = mock("TemplateRenderer")
				context = mock("Context")
			})

			describe(".render", function () {

				it("should render the template using the model", function () {
					mock({
						$object: templateRenderer,
						render: {
							$args: [template, model],
							$returns: "result",
							$times: 1
						}
					})

					var view = new TemplateView(templateRenderer, template)
					view.templateRenderer = templateRenderer

					expect(view.render(model, context)).toBe("result")

					verify(templateRenderer)
				})

				// it("should pass the given properties to the template", function () {
				// 	var properties = {
				// 		property1: "one",
				// 		property2: "two",
				// 		property3: "three"
				// 	}
				// 	// The model being rendered is the model and the properties combined.
				// 	var renderedModel = Duplicate(model, false).append(properties)
				// 	mock({
				// 		$object: templateRenderer,
				// 		render: {
				// 			$args: [template, renderedModel],
				// 			$returns: "result",
				// 			$times: 1
				// 		}
				// 	})

				// 	var view = new TemplateView(template, properties)
				// 	view.templateRenderer = templateRenderer

				// 	// The view receives the model without the properties.
				// 	expect(view.render(model, context)).toBe("result")

				// 	verify(templateRenderer)
				// })

			})

		})
	}

}