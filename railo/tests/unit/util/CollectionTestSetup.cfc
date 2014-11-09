import craft.util.*;

component extends="testbox.system.BaseSpec" skip="true" {

	private Collection function createCollection() {
		Throw("Not implemented")
	}

	function run() {

		describe("collection", function () {

			beforeEach(function () {
				collection = createCollection()
			})

			describe("without items", function () {

				describe(".isEmpty", function () {
					it("should return true", function () {
						expect(createCollection().isEmpty()).toBeTrue()
					})
				})

				describe(".add", function () {
					it("should return true if the item is not in the collection", function () {
						var item = {id: 1}
						expect(collection.add(item)).toBeTrue("item should have been added successfully")
						expect(collection.isEmpty()).toBeFalse("collection should not be empty")
						expect(collection.add(item)).toBeFalse("adding the item twice should return false")
					})
				})

			})

			describe("with items", function () {

				beforeEach(function () {
					item1 = {id: 1}
					item2 = {id: 2}
					item3 = {id: 3}
					collection.add(item1)
					collection.add(item2)
					collection.add(item3)
				})

				describe(".toArray", function () {
					it("should return an array of items", function () {
						expect(collection.toArray()).toBe([item1, item2, item3])
					})
				})

				describe(".size", function () {
					it(" should return the number of items", function () {
						expect(collection.size()).toBe(3)
					})
				})

				describe(".add", function () {
					it("should return false if the referenced item is not in the collection", function () {
						expect(collection.add({id: "A"}, {id: "B"})).toBeFalse()
					})
				})

				describe(".contains", function () {
					it("should return the correct boolean value", function () {
						expect(collection.contains(item1)).toBeTrue("item1 should be in the collection")
						expect(collection.contains(item2)).toBeTrue("item2 should be in the collection")
						expect(collection.contains(item3)).toBeTrue("item3 should be in the collection")
						expect(collection.contains({id: "A"}), "item should not be in the collection")
					})
				})

				describe(".move", function () {

					it("should place the item at the correct index and return true", function () {
						// Move item2 before item1
						expect(collection.move(item2, item1)).toBeTrue()
						expect(collection.toArray()).toBe([item2, item1, item3])

						// Move item3 before item2
						expect(collection.move(item3, item2)).toBeTrue()
						expect(collection.toArray()).toBe([item3, item2, item1])
					})

					it("should place item at the end if no reference item is provided and return true", function () {
						expect(collection.move(item1)).toBeTrue()
						expect(collection.toArray()).toBe([item2, item3, item1])
					})

					it("should return false if moved the reference item is not in the collection", function () {
						expect(collection.move(item1, {id: "A"})).toBeFalse()
					})

					it("should return false if the item is moved before itself", function () {
						expect(collection.move(item1, item1)).toBeFalse()
					})

					it("should return false if the item is not in the collection", function () {
						expect(collection.move({id: "A"})).toBeFalse()
					})

				})

				describe(".remove", function () {

					it("should remove the item and return true", function () {
						expect(collection.remove(item1)).toBeTrue()
						expect(collection.contains(item1)).toBeFalse("collection.contains should return false if the item is removed")
						expect(collection.toArray()).toBe([item2, item3])
						expect(collection.size()).toBe(2)
					})

					it("should return false if the item is not in the collection", function () {
						expect(collection.remove({id: "A"})).toBeFalse()
					})

				})

				describe(".select", function () {

					it("should return matching item", function () {
						var selected = collection.select(function (item) {
							return arguments.item.id == 1;
						})
						expect(selected).toBe(item1)
					})

					it("should return null if no item matches", function () {
						var selected = this.collection.select(function (item) {
							return arguments.item.id == "A";
						})
						expect(selected).toBeNull()
					})

				})

			})

		})

	}

}