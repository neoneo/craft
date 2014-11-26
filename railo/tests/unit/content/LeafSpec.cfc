import craft.content.Leaf;

component extends="tests.MocktorySpec" {

	function run() {

		describe("Leaf", function () {

			beforeEach(function () {
				leaf = new Leaf()
			})

			describe(".hasChildren", function () {

				it("should always return false", function () {
					expect(leaf.hasChildren).toBeFalse()
				})

			})

			describe(".accept", function () {

				it("should invoke the visitor", function () {
					var visitor = mock({
						$interface: "Visitor",
						visitLeaf: {
							$args: [leaf],
							$returns: null,
							$times: 1
						}
					})

					leaf.accept(visitor)

					verify(visitor)
				})

			})

		})

	}

}