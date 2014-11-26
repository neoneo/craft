import craft.content.Placeholder;

component extends="tests.MocktorySpec" {

	function run() {

		describe("Placeholder", function () {

			beforeEach(function () {
				placeholder = new Placeholder("ref")
			})

			describe(".ref", function () {

				it("should return the constructor value", function () {
					expect(placeholder.ref).toBe("ref")
				})

			})

			describe(".accept", function () {

				it("should invoke the visitor", function () {
					var visitor = mock({
						$interface: "Visitor",
						visitPlaceholder: {
							$args: [placeholder],
							$returns: null,
							$times: 1
						}
					})

					placeholder.accept(visitor)

					verify(visitor)
				})

			})

		})

	}

}