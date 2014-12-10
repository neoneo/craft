import craft.markup.Scope;

component extends="tests.MocktorySpec" {

	function run() {

		describe("Scope", function () {

			describe("without parent", function () {

				beforeEach(function () {
					scope = new Scope()
					element = mock({
						$class: "Element",
						ref: "ref"
					})
				})

				describe(".put", function () {

					it("should store the element if it has a ref", function () {
						scope.put(element)
						scope.get("ref") // Hard to test actual storage otherwise.
					})

					it("should throw AlreadyBoundException if an element with the same ref is already available", function () {
						scope.put(element)
						element2 = mock({
							$class: "Element",
							ref: "ref"
						})

						expect(function () {
							scope.put(element2)
						}).toThrow("AlreadyBoundException")
					})

				})

				describe(".has", function () {

					it("should return false if the ref does not exist", function () {
						expect(scope.has("doesnotexist")).toBeFalse()

						scope.put(element)
						expect(scope.has("doesnotexist")).toBeFalse()
					})

					it("should return true if the ref exists", function () {
						scope.put(element)

						expect(scope.has("ref")).toBeTrue()
					})

				})

				describe(".get", function () {

					it("should throw NoSuchElementException if the ref does not exist", function () {
						scope.put(element)

						expect(function () {
							scope.get("doesnotexist")
						}).toThrow("NoSuchElementException")
					})

					it("should return the element with the ref", function () {
						scope.put(element)

						var result = scope.get("ref")
						$assert.isSameInstance(element, result)
					})

				})

			})

			describe("with parent", function () {

				beforeEach(function () {
					parent = new Scope()
					scope = new Scope(parent)

					// Create 2 elements with the same ref.
					element1 = mock({
						$class: "Element",
						ref: "ref"
					})
					element2 = mock({
						$class: "Element",
						ref: "ref"
					})
				})

				describe(".put", function () {

					it("should store the element if an element with that ref exists in the parent", function () {
						parent.put(element1)
						scope.put(element2)
					})

				})

				describe(".has", function () {

					it("should return true if the parent has the element", function () {
						parent.put(element1)

						expect(scope.has("ref")).toBeTrue()
					})

				})

				describe(".get", function () {

					it("should return the element with the ref if the parent has the element", function () {
						parent.put(element1)

						var result = scope.get("ref")
						$assert.isSameInstance(element1, result)
					})

					it("should return the element with the ref from the closest scope", function () {
						parent.put(element1)
						scope.put(element2)

						var result = scope.get("ref")
						$assert.isSameInstance(element2, result)
					})

				})

			})

		})

	}

}