import craft.util.*;

component extends="mxunit.framework.TestCase" {

	private Collection function createCollection() {
		Throw("Not implemented")
	}

	public void function setUp() {
		variables.collection = createCollection()
		variables.item1 = {id: 1}
		variables.item2 = {id: 2}
		variables.item3 = {id: 3}
		variables.collection.add(variables.item1)
		variables.collection.add(variables.item2)
		variables.collection.add(variables.item3)
	}

	public void function AfterCreation_Should_BeEmpty() {
		assertTrue(createCollection().isEmpty(), "collection should be empty after creation")
	}

	public void function Add_Should_ReturnCorrectBooleanValue() {
		var item = {id: "A"}
		assertTrue(variables.collection.add(item), "collection.add should return true if the item is not in the list")
		assertFalse(variables.collection.isEmpty(), "collection should not be empty")
		assertFalse(variables.collection.add(item), "collection.add should return false if the item is in the list")
	}

	public void function Add_Should_ReturnFalse_IfInsertedBeforeNotExists() {
		assertFalse(collection.add({id: "A"}, {id: "B"}), "collection.add should return false if the item should be moved before an item that is not in the list")
	}

	public void function Contains_Should_ReturnCorrectBooleanValue() {
		assertTrue(variables.collection.contains(variables.item1))
		assertTrue(variables.collection.contains(variables.item2))
		assertTrue(variables.collection.contains(variables.item3))
		assertFalse(variables.collection.contains({id: "A"}), "collection.contains should return false for new item")
	}

	public void function Size_Should_ReturnNumberOfItems() {
		assertEquals(3, variables.collection.size())
	}

	public void function Move_Should_ReturnTrue_IfMovedBackward() {
		assertTrue(variables.collection.move(variables.item2, variables.item1))
	}

	public void function Move_Should_ReturnTrue_IfMovedForward() {
		assertTrue(variables.collection.move(variables.item3, variables.item2))
	}

	public void function Move_Should_ReturnTrue_IfMoveToTheEnd() {
		assertTrue(variables.collection.move(variables.item1))
	}

	public void function Move_Should_ReturnFalse_IfMovedBeforeNotExists() {
		assertFalse(variables.collection.move(variables.item1, {id: "A"}))
	}

	public void function Move_Should_ReturnFalse_IfMovedBeforeItself() {
		assertFalse(variables.collection.move(variables.item1, variables.item1))
	}

	public void function Move_Should_ReturnFalse_IfNotExists() {
		assertFalse(variables.collection.move({id: "A"}, variables.item1), "collection.move should return false if the item to be moved is not in the list")
	}

	public void function Remove_Should_ReturnTrue_IfExists() {
		assertTrue(variables.collection.remove(variables.item1))
		assertFalse(variables.collection.contains(variables.item1), "collection.contains should return false if the item is removed")
		assertFalse(variables.collection.remove(variables.item1), "collection.remove should return false if the item is not in the list")
		assertEquals(2, collection.size())
	}

	public void function Remove_Should_ReturnFalse_IfNotExists() {
		assertFalse(variables.collection.remove({id: "A"}), "collection.remove should return false if the item is not in the list")
	}

	public void function ToArray_Should_ReturnCorrectOrderAfterAdd() {
		var array = variables.collection.toArray()
		assertEquals(3, array.len(), "array should have 3 items")
		assertSame(array[1], variables.item1, "item1 should be at index 1")
		assertSame(array[2], variables.item2, "item2 should be at index 2")
		assertSame(array[3], variables.item3, "item3 should be at index 3")
	}

	public void function ToArray_Should_ReturnCorrectOrderAfterMove() {
		variables.collection.move(variables.item2, variables.item1)
		variables.collection.move(variables.item3, variables.item2)
		var array = variables.collection.toArray()
		assertEquals(3, array.len(), "array should have 3 items")
		assertSame(array[1], variables.item3, "item3 should be at index 1")
		assertSame(array[2], variables.item2, "item2 should be at index 2")
		assertSame(array[3], variables.item1, "item1 should be at index 3")
	}

	public void function ToArray_Should_ReturnCorrectOrderAfterRemove() {
		variables.collection.remove(variables.item2)
		var array = variables.collection.toArray()
		assertEquals(2, array.len(), "array should have 2 items")
		assertSame(array[1], variables.item1, "item1 should be at index 1")
		assertSame(array[2], variables.item3, "item3 should be at index 2")
	}

	public void function Select_Should_ReturnItemThatMatches() {

		var selected = variables.collection.select(function (item) {
			return arguments.item === variables.item1
		})
		assertSame(selected, variables.item1, "collection.select should return item1")
		var noChild = {id: "A"}
		var selected = collection.select(function (item) {
			return arguments.item === noChild
		})
		assertTrue(selected === null, "collection.select should return null if the predicate is not met")
	}

}