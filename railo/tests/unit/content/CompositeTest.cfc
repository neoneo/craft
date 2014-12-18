import craft.content.Composite;

component extends="tests.MocktorySpec" {

	function run() {

		describe("Composite", function () {

			beforeEach(function () {
				composite = new Composite()
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
								$args: [composite],
								$returns: null,
								$times: 1
							}
						})

						composite.accept(visitor)

						verify(visitor)
					})

				})

				describe(".traverse", function () {

					it("should call accept on all children", function () {
						mock({
							$object: composite,
							children: [
								{$class: "Leaf", accept: null},
								{$class: "Leaf", accept: null},
								{$class: "Leaf", accept: null}
							]
						})

						composite.traverse(visitor)

						composite.children.each(function (child) {
							verify(arguments.child, {
								accept: {
									$args: [visitor],
									$times: 1
								}
							})
						})
					})

				})

			})

			describe("child relationship", function () {

				beforeEach(function () {
					collection = mock({
						$class: "Collection",
						isEmpty: true,
						toArray: []
					})
					mock(composite)
					composite.$property("childCollection", "this", collection)
				})

				describe(".children", function () {

					it("should return all children as an array", function () {
						expect(composite.children).toBeArray()
						verify(collection, {
							toArray: {
								$times: 1
							}
						})
					})

				})

				describe(".hasChildren", function () {

					it("should return whether the composite has any children", function () {
						expect(composite.hasChildren).toBeFalse() // The negation of isEmpty.
						expect(collection.$count("isEmpty")).toBe(1)
					})

				})

				describe(".addChild", function () {

					beforeEach(function () {
						mock({
							$object: collection,
							add: {
								$results: [true, false]
							}
						})
					})

					it("should add the child to the end and set the parent on the child when successful", function () {
						var child1 = mock("Component")

						var success = composite.addChild(child1)

						expect(success).toBeTrue()
						verify(collection, {
							add: {
								$args: [child1, null],
								$times: 1
							}
						})
						$assert.isSameInstance(composite, child1.parent)

						// Add another child. The collection will now return false.
						var child2 = mock("Component")

						var success = composite.addChild(child2)

						expect(success).toBeFalse()
						verify(collection, {
							add: {
								$args: [child2, null],
								$times: 1
							}
						})
						expect(child2.parent).toBeNull()
					})

					it("should add the child before the existing child and set the parent on the child when successful", function () {
						var child = mock("Component")
						var beforeChild = mock("Component")

						var success = composite.addChild(child, beforeChild)

						expect(success).toBeTrue()
						verify(collection, {
							add: {
								$args: [child, beforeChild],
								$times: 1
							}
						})
						$assert.isSameInstance(composite, child.parent)
					})

				})

				describe(".removeChild", function () {

					beforeEach(function () {
						mock({
							$object: collection,
							remove: {
								$results: [true, false]
							}
						})
					})

					it("should remove if the composite is a child, and set its parent to null when successful", function () {
						var child1 = mock("Component")
						child1.parent = composite

						var success = composite.removeChild(child1)

						expect(success).toBeTrue()
						verify(collection, {
							remove: {
								$args: [child1],
								$times: 1
							}
						})
						expect(child1.parent).toBeNull()

						// Remove another child. This will now return false.
						var child2 = mock("Component")
						child2.parent = child1

						var success = composite.removeChild(child2)

						expect(success).toBeFalse()
						verify(collection, {
							remove: {
								$args: [child2],
								$times: 1
							}
						})
						$assert.isSameInstance(child1, child2.parent)
					})

				})

				describe(".moveChild", function () {

					beforeEach(function () {
						mock({
							$object: collection,
							move: true
						})
					})

					it("should move the child to the end if no before child is provided", function () {
						var child = mock("Component")

						var success = composite.moveChild(child)

						expect(success).toBeTrue()
						verify(collection, {
							move: {
								$args: [child, null],
								$times: 1
							}
						})
					})

					it("should move the child before the existing child", function () {
						var child = mock("Component")
						var beforeChild = mock("Component")

						var success = composite.moveChild(child, beforeChild)

						expect(success).toBeTrue()
						verify(collection, {
							move: {
								$args: [child, beforeChild],
								$times: 1
							}
						})
					})

				})

			})

		})

	}

}