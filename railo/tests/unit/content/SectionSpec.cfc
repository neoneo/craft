import craft.content.Section;

component extends="tests.MocktorySpec" {

	function run() {

		describe("Section", function () {

			beforeEach(function () {
				section = new Section()
			})

			describe("visitor interaction", function () {

				beforeEach(function () {
					visitor = mock({
						$interface: "Visitor"
					})
				})

				describe(".accept", function () {

					it("should invoke the visitor", function () {
						mock(visitor, {
							visitComposite: {
								$args: [section],
								$returns: null,
								$times: 1
							}
						})

						section.accept(visitor)

						verify(visitor)
					})

				})

				describe(".traverse", function () {

					it("should call accept on all components", function () {
						mock({
							$object: section,
							components: [
								{$class: "Leaf", accept: null},
								{$class: "Leaf", accept: null},
								{$class: "Leaf", accept: null}
							]
						})

						section.traverse(visitor)

						section.components.each(function (component) {
							verify(arguments.component, {
								accept: {
									$args: [visitor],
									$times: 1
								}
							})
						})
					})

				})

			})

			describe(".placeholders", function () {

				it("should return all descendant placeholders", function () {
					// Build a tree with placeholders at several levels.
					mock({
						$object: section,
						components: [
							{
								$class: "Composite",
								hasChildren: true,
								children: [
									{
										$class: "Placeholder",
										ref: "p1"
									},
									{
										$class: "Composite",
										hasChildren: false,
										children: []
									},
									{
										$class: "Composite",
										hasChildren: true,
										children: [
											{
												$class: "Leaf"
											},
											{
												$class: "Composite",
												hasChildren: true,
												children: [
													{
														$class: "Placeholder",
														ref: "p3"
													}
												]
											},
											{
												$class: "Placeholder",
												ref: "p2"
											}
										]
									}
								]
							},
							{
								$class: "Composite",
								hasChildren: true,
								children: [
									{
										$class: "Placeholder",
										ref: "p4"
									}
								]
							}
						]
					})

					var placeholders = section.placeholders

					expect(placeholders.len()).toBe(4)
					var refs = placeholders.map(function (placeholder) {
						return arguments.placeholder.ref;
					}).sort("text")
					expect(refs).toBe(["p1", "p2", "p3", "p4"])
				})

			})

			describe("component relationship", function () {

				beforeEach(function () {
					collection = mock({
						$class: "Collection",
						isEmpty: true,
						toArray: []
					})
					mock(section)
					section.$property("componentCollection", "this", collection)
				})

				describe(".components", function () {

					it("should return all components as an array", function () {
						expect(section.components).toBeArray()
						verify(collection, {
							toArray: {
								$times: 1
							}
						})
					})

				})

				describe(".hasComponents", function () {

					it("should return whether the section has any components", function () {
						expect(section.hasComponents).toBeFalse() // The negation of isEmpty.
						expect(collection.$count("isEmpty")).toBe(1)
					})

				})

				describe(".addComponent", function () {

					beforeEach(function () {
						mock({
							$object: collection,
							add: true
						})
					})

					it("should add the component to the end", function () {
						var component = mock("Component")

						var success = section.addComponent(component)

						expect(success).toBeTrue()
						verify(collection, {
							add: {
								$args: [component, null],
								$times: 1
							}
						})
					})

					it("should add the component before the existing component", function () {
						var component = mock("Component")
						var beforeComponent = mock("Component")

						var success = section.addComponent(component, beforeComponent)

						expect(success).toBeTrue()
						verify(collection, {
							add: {
								$args: [component, beforeComponent],
								$times: 1
							}
						})
					})

				})

				describe(".removeComponent", function () {

					beforeEach(function () {
						mock({
							$object: collection,
							remove: true
						})
					})

					it("should remove if the section is a component", function () {
						var component = mock("Component")

						var success = section.removeComponent(component)

						expect(success).toBeTrue()
						verify(collection, {
							remove: {
								$args: [component],
								$times: 1
							}
						})
					})

				})

				describe(".moveComponent", function () {

					beforeEach(function () {
						mock({
							$object: collection,
							move: true
						})
					})

					it("should move the component to the end if no before component is provided", function () {
						var component = mock("Component")

						var success = section.moveComponent(component)

						expect(success).toBeTrue()
						verify(collection, {
							move: {
								$args: [component, null],
								$times: 1
							}
						})
					})

					it("should move the component before the existing component", function () {
						var component = mock("Component")
						var beforeComponent = mock("Component")

						var success = section.moveComponent(component, beforeComponent)

						expect(success).toBeTrue()
						verify(collection, {
							move: {
								$args: [component, beforeComponent],
								$times: 1
							}
						})
					})

				})

			})

		})

	}

}