import craft.content.DocumentLayout;

component extends="tests.MocktorySpec" {

	function run() {

		describe("DocumentLayout", function () {

			beforeEach(function () {
				layout = mock({
					$class: "Layout",
					placeholders: [
						{$class: "Placeholder", ref: "p1"},
						{$class: "Placeholder", ref: "p2"}
					]
				})

				document = new DocumentLayout(layout)
			})

			describe(".placeholders", function () {

				it("should return the placeholders from the layout", function () {
					var placeholders = document.placeholders
					expect(placeholders).toHaveLength(2, "since no placeholders are filled, the placeholders of the layout should be returned")
					expect(refs(placeholders)).toBe(["p1", "p2"])

					// Fill one of the placeholders.
					mock(document).$property("sections", "this", {
						p2: mock({
							$class: "Section",
							placeholders: [
								{$class: "Placeholder", ref: "p3"},
								{$class: "Placeholder", ref: "p4"}
							]
						})
					})

					var placeholders = document.placeholders
					expect(placeholders).toHaveLength(3, "p2 should have been replaced by p3 and p4, so there should be 3 placeholders")
					expect(refs(placeholders)).toBe(["p1", "p3", "p4"])
				})

				it("should return the placeholders from ancestor layouts", function () {
					// Fill placeholder p2.
					mock(document).$property("sections", "this", {
						p2: mock({
							$class: "Section",
							placeholders: [
								// This effectively replaces p1 by p2.
								{$class: "Placeholder", ref: "p3"}
							]
						})
					})

					var document2 = new DocumentLayout(document)

					var placeholders = document2.placeholders
					expect(placeholders).toHaveLength(2, "document2 should have the same placeholders as document")
					expect(refs(placeholders)).toBe(["p1", "p3"])

					// Now fill p1, which is defined in the layout.
					mock(document2).$property("sections", "this", {
						p1: mock({
							$class: "Section",
							// This 'removes' p1.
							placeholders: []
						})
					})

					var placeholders = document2.placeholders
					expect(placeholders).toHaveLength(1)
					expect(refs(placeholders)).toBe(["p3"])

					// Now fill p3. Get the sections and append.
					document2.sections.p3 = mock({
						$class: "Section",
						placeholders: [
							{$class: "Placeholder", ref: "p4"}
						]
					})

					var placeholders = document2.placeholders
					expect(placeholders).toHaveLength(1)
					expect(refs(placeholders)).toBe(["p4"])

					// Add another level.
					var document3 = new DocumentLayout(document2)
					var placeholders = document3.placeholders
					expect(placeholders).toHaveLength(1, "document3 should have the same placeholders as document2")
					expect(refs(placeholders)).toBe(["p4"])

					mock(document3).$property("sections", "this", {
						p4: mock({
							$class: "Section",
							placeholders: [
								{$class: "Placeholder", ref: "p5"},
								{$class: "Placeholder", ref: "p6"}
							]
						})
					})

					var placeholders = document3.placeholders
					expect(placeholders).toHaveLength(2, "p4 should have been replaced by p5 and p6, so there should be 2 placeholders")
					expect(refs(placeholders)).toBe(["p5", "p6"])

					// The parent documents should not be affected.
					var placeholders = document2.placeholders
					expect(placeholders).toHaveLength(1)
					expect(refs(placeholders)).toBe(["p4"])

					var placeholders = document.placeholders
					expect(placeholders).toHaveLength(2)
					expect(refs(placeholders)).toBe(["p1", "p3"])

					var placeholders = layout.placeholders
					expect(placeholders).toHaveLength(2)
					expect(refs(placeholders)).toBe(["p1", "p2"])
				})

			})

		})

	}

	function refs(placeholders) {
		return arguments.placeholders.map(function (placeholder) {
			return arguments.placeholder.ref;
		}).sort("text");
	}

}