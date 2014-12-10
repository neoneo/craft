import craft.markup.Element;

component extends="tests.MocktorySpec" {

	function run() {

		describe("Element", function () {

			beforeEach(function () {
				element = new Element()
			})

			describe(".ready", function () {

				it("should return false if the element has no product", function () {
					expect(element.ready).toBeFalse()
				})

				it("should return true if the element has a product", function () {
					var product = mock("Component")
					makePublic(element, "setProduct")
					element.setProduct(product)

					expect(element.ready).toBeTrue()
				})

			})

			describe(".childrenReady", function () {

				it("should return true if there are no children", function () {
					expect(element.childrenReady).toBeTrue()
				})

				it("should return false if at least one child is not ready", function () {
					element.children = [
						mock({
							$class: "Element",
							ready: true
						}),
						mock({
							$class: "Element",
							ready: false
						})
					]

					expect(element.childrenReady).toBeFalse()
				})

				it("should return true if all children are ready", function () {
					element.children = [
						mock({
							$class: "Element",
							ready: true
						}),
						mock({
							$class: "Element",
							ready: true
						})
					]

					expect(element.childrenReady).toBeTrue()
				})

			})

			describe(".parent", function () {

				it("should set and get a parent element", function () {
					expect(element.hasParent).toBeFalse()

					var parent = mock("Element")

					element.parent = parent

					$assert.isSameInstance(parent, element.parent)
					expect(element.hasParent).toBeTrue()
				})

			})

			describe(".children", function () {

				it("should set and get child elements", function () {
					expect(element.hasChildren).toBeFalse()

					var child1 = mock("Element")
					var child2 = mock("Element")

					element.add(child1)

					expect(element.hasChildren).toBeTrue()

					element.add(child2)

					var children = element.children

					expect(children).toHaveLength(2)
					$assert.isSameInstance(child1, children[1])
					$assert.isSameInstance(child2, children[2])
					// The parent should have been set on the children.
					$assert.isSameInstance(element, children[1].parent)
					$assert.isSameInstance(element, children[2].parent)
				})
			})

			describe("and siblings", function () {

				beforeEach(function () {
					children = [
						new Element(),
						new Element(),
						new Element()
					]
				})

				describe(".siblingIndex", function () {

					it("should return 0 if the element has no parent", function () {
						expect(children[1].siblingIndex).toBe(0)
					})

					it("should return the position of the element amongst its siblings", function () {
						element.add(children[1])
						element.add(children[2])
						element.add(children[3])

						expect(children[1].siblingIndex).toBe(1)
						expect(children[2].siblingIndex).toBe(2)
						expect(children[3].siblingIndex).toBe(3)
					})

				})

				describe(".siblings", function () {

					it("should return an empty array if the element has no parent", function () {
						expect(children[1].siblings).toBeEmpty()
					})

					it("should return an empty array if the element has no siblings", function () {
						element.add(children[1])
						expect(children[1].siblings).toBeEmpty()
					})

					it("should return the siblings of the element", function () {
						element.add(children[1])
						element.add(children[2])
						element.add(children[3])

						var siblings = children[1].siblings;

						expect(siblings).toHaveLength(children.len() - 1)
						$assert.isSameInstance(children[2], siblings[1])
						$assert.isSameInstance(children[3], siblings[2])
					})

				})

			})

		})

	}

}