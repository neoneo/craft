import craft.util.*;

component extends="mxunit.framework.TestCase" {

	private Collection function createCollection() {
		Throw("Not implemented")
	}

	public void function setUp() {
		this.collection = createCollection()
		this.item1 = {id: 1}
		this.item2 = {id: 2}
		this.item3 = {id: 3}
		this.collection.add(this.item1)
		this.collection.add(this.item2)
		this.collection.add(this.item3)
	}

	public void function AfterCreation_Should_BeEmpty() {
		assertTrue(createCollection().isEmpty(), "collection should be empty after creation")
	}

	public void function Add_Should_ReturnCorrectBooleanValue() {
		var item = {id: "A"}
		assertTrue(this.collection.add(item), "collection.add should return true if the item is not in the list")
		assertFalse(this.collection.isEmpty(), "collection should not be empty")
		assertFalse(this.collection.add(item), "collection.add should return false if the item is in the list")
	}

	public void function Add_Should_ReturnFalse_IfInsertedBeforeNotExists() {
		assertFalse(collection.add({id: "A"}, {id: "B"}), "collection.add should return false if the item should be moved before an item that is not in the list")
	}

	public void function Contains_Should_ReturnCorrectBooleanValue() {
		assertTrue(this.collection.contains(this.item1))
		assertTrue(this.collection.contains(this.item2))
		assertTrue(this.collection.contains(this.item3))
		assertFalse(this.collection.contains({id: "A"}), "collection.contains should return false for new item")
	}

	public void function Size_Should_ReturnNumberOfItems() {
		assertEquals(3, this.collection.size())
	}

	public void function Move_Should_ReturnTrue_IfMovedBackward() {
		assertTrue(this.collection.move(this.item2, this.item1))
	}

	public void function Move_Should_ReturnTrue_IfMovedForward() {
		assertTrue(this.collection.move(this.item3, this.item2))
	}

	public void function Move_Should_ReturnTrue_IfMoveToTheEnd() {
		assertTrue(this.collection.move(this.item1))
	}

	public void function Move_Should_ReturnFalse_IfMovedBeforeNotExists() {
		assertFalse(this.collection.move(this.item1, {id: "A"}))
	}

	public void function Move_Should_ReturnFalse_IfMovedBeforeItself() {
		assertFalse(this.collection.move(this.item1, this.item1))
	}

	public void function Move_Should_ReturnFalse_IfNotExists() {
		assertFalse(this.collection.move({id: "A"}, this.item1), "collection.move should return false if the item to be moved is not in the list")
	}

	public void function Remove_Should_ReturnTrue_IfExists() {
		assertTrue(this.collection.remove(this.item1))
		assertFalse(this.collection.contains(this.item1), "collection.contains should return false if the item is removed")
		assertFalse(this.collection.remove(this.item1), "collection.remove should return false if the item is not in the list")
		assertEquals(2, collection.size())
	}

	public void function Remove_Should_ReturnFalse_IfNotExists() {
		assertFalse(this.collection.remove({id: "A"}), "collection.remove should return false if the item is not in the list")
	}

	public void function ToArray_Should_ReturnCorrectOrderAfterAdd() {
		var array = this.collection.toArray()
		assertEquals(3, array.len(), "array should have 3 items")
		assertSame(array[1], this.item1, "item1 should be at index 1")
		assertSame(array[2], this.item2, "item2 should be at index 2")
		assertSame(array[3], this.item3, "item3 should be at index 3")
	}

	public void function ToArray_Should_ReturnCorrectOrderAfterMove() {
		this.collection.move(this.item2, this.item1)
		this.collection.move(this.item3, this.item2)
		var array = this.collection.toArray()
		assertEquals(3, array.len(), "array should have 3 items")
		assertSame(array[1], this.item3, "item3 should be at index 1")
		assertSame(array[2], this.item2, "item2 should be at index 2")
		assertSame(array[3], this.item1, "item1 should be at index 3")
	}

	public void function ToArray_Should_ReturnCorrectOrderAfterRemove() {
		this.collection.remove(this.item2)
		var array = this.collection.toArray()
		assertEquals(2, array.len(), "array should have 2 items")
		assertSame(array[1], this.item1, "item1 should be at index 1")
		assertSame(array[2], this.item3, "item3 should be at index 2")
	}

	public void function Select_Should_ReturnItemThatMatches() {

		var selected = this.collection.select(function (item) {
			return arguments.item === this.item1
		})
		assertSame(selected, this.item1, "collection.select should return item1")
		var noChild = {id: "A"}
		var selected = collection.select(function (item) {
			return arguments.item === noChild
		})
		assertTrue(selected === null, "collection.select should return null if the predicate is not met")
	}

}