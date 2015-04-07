import craft.util.ObjectProvider;

component extends="tests.MocktorySpec" {

	function run() {

		describe("ObjectProvider", function () {

			beforeEach(function () {
				objectProvider = new ObjectProvider()
			})

			xdescribe(".registerAll", function () {

				beforeEach(function () {
					metadata = mock({
						$class: "Metadata",
						scan: [
							// GetComponentMetadata(),
							// GetComponentMetadata(),
							// GetComponentMetadata(),
							// GetComponentMetadata(),
						]
					})
					mock(objectProvider).$property("metadata", "this", metadata)
				})

			})

		})

	}

}