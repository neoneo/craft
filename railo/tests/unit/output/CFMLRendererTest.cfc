import craft.output.CFMLRenderer;

component extends="testbox.system.BaseSpec" {

	function run() {

		describe("CFMLRenderer", function () {

			beforeEach(function () {
				renderer = new CFMLRenderer()
				renderer.addMapping("/tests/unit/output/cfmlrenderer")
				template = "renderer"
			})

			describe(".render", function () {

				it("should return output as a string", function () {
					expect(renderer.render(template, {})).toBeTypeOf("string")
				})

				it("should pass the model to the template for rendering", function () {
					var model = {
						number: 1,
						string: "string",
						boolean: true,
						date: Now()
					}
					var output = renderer.render(template, model)
					// This template just serializes the model to JSON.
					expect(IsJSON(output)).toBeTrue()
					var deserialized = DeserializeJSON(output)
					// All keys in the model should exist and have the same values.
					for (var key in model) {
						expect(deserialized).toHaveKey(key)
						expect(deserialized[key]).toBe(model[key], "key '#key#' should be the same in the model and the returned JSON string")
					}
				})

			})

		})

	}

}