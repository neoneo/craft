import craft.content.Document;

component extends="tests.MocktorySpec" {

	function run() {

		describe("Document", function () {

			beforeEach(function() {
				layout = mock({
					$class: "Layout",
					placeholders: [
						{$class: "Placeholder", ref: "p1"},
						{$class: "Placeholder", ref: "p2"}
					]
				})

				document = new Document(layout)
			})

			describe(".accept", function () {

				it("should invoke the visitor", function () {
					var visitor = mock({
						$interface: "Visitor",
						visitDocument: {
							$args: [document],
							$returns: null,
							$times: 1
						}
					})

					document.accept(visitor)

					verify(visitor)
				})

			})

			describe("filling placeholders", function () {

				beforeEach(function () {
					section1 = mock("Section")
					section2 = mock("Section")
				})

				describe(".fillPlaceholder", function () {

					it("should throw NoSuchElementException if the placeholder does not exist", function () {
						expect(function () {
							document.fillPlaceholder("placeholder", section1)
						}).toThrow("NoSuchElementException")
					})

					it("should fill the placeholder and return true if it is not yet filled", function () {
						expect(document.sections.isEmpty()).toBeTrue()

						expect(document.fillPlaceholder("p1", section1)).toBeTrue()
						expect(document.fillPlaceholder("p1", section2)).toBeFalse()
						expect(document.fillPlaceholder("p2", section2)).toBeTrue()

						var sections = document.sections
						expect(sections.len()).toBe(2)
						expect(sections).toHaveKey("p1")
						expect(sections).toHaveKey("p2")
						$assert.isSameInstance(section1, sections.p1)
						$assert.isSameInstance(section2, sections.p2)
					})

				})

				describe(".clearPlaceholder", function () {

					it("should clear the placeholder and return true if it was filled", function () {
						expect(document.clearPlaceholder("p1")).toBeFalse()

						document.fillPlaceholder("p1", section1)
						document.fillPlaceholder("p2", section2)

						expect(document.clearPlaceholder("p1")).toBeTrue()
						expect(document.clearPlaceholder("p1")).toBeFalse()

						var sections = document.sections
						expect(sections.len()).toBe(1)
						expect(sections).toHaveKey("p2")
						$assert.isSameInstance(section2, sections.p2)
					})
				})

			})

			describe(".replaceLayout", function () {

				it("should keep placeholders with existing refs and remove all others", function () {
					var section1 = mock("Section")
					var section2 = mock("Section")
					document.fillPlaceholder("p1", section1)
					document.fillPlaceholder("p2", section2)

					// Replace the layout by the following layout.
					var layout2 = mock({
						$class: "Layout",
						placeholders: [
							// This layout has one placeholder in common.
							{$class: "Placeholder", ref: "p1"},
							{$class: "Placeholder", ref: "p3"}
						]
					})

					document.replaceLayout(layout2)

					$assert.isSameInstance(layout2, document.layout)

					var sections = this.document.sections
					expect(sections.len()).toBe(1, "the old and new layout have one placeholder in common, so there should be one key")
					expect(sections).toHaveKey("p1")
					$assert.isSameInstance(section1, sections.p1)

					expect(function () {
						document.fillPlaceholder("p2", section2)
					}).toThrow("NoSuchElementException")

					expect(document.fillPlaceholder("p3", section2)).toBeTrue()
					expect(document.sections).toHaveKey("p3")
				})

			})

		})

	}

}