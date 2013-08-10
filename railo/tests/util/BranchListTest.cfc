component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		variables.parent = new BranchStub();
	}

	public void function ScopeBranchList() {
		var branchList = new craft.core.util.ScopeBranchList(variables.parent)
		test(branchList)
	}

	public void function CacheBranchList() {
		var cache = new craft.core.util.ScopeCache()
		var branchList = new craft.core.util.CacheBranchList(variables.parent, cache)
		test(branchList)
	}

	private void function test(required craft.core.util.BranchList branchList) {

		var branchList = arguments.branchList
		assertEquals(variables.parent, branchList.getParent(), "parent should be the object passed to the constructor")
		assertTrue(branchList.isEmpty(), "branchList should be empty")

		var child1 = new BranchStub()
		var child2 = new BranchStub()
		var child3 = new BranchStub()

		assertTrue(branchList.add(child1), "branchList.add should return true if the item is not in the list")
		assertFalse(branchList.isEmpty(), "branchList should not be empty")
		assertFalse(branchList.add(child1), "branchList.add should return false if the item is in the list")

		var child4 = new BranchStub()
		child4.setParent(child1)
		assertFalse(branchList.add(child4), "branchList.add should return false if the item has a parent")

		assertFalse(branchList.add(child2, child3), "branchList.add should return false if the item should be moved before an item that is not in the list")
		branchList.add(child3)
		branchList.add(child2)

		assertTrue(branchList.contains(child1), "branchList should contain child1")
		assertTrue(branchList.contains(child2), "branchList should contain child2")
		assertTrue(branchList.contains(child3), "branchList should contain child3")

		assertEquals(3, branchList.size(), "size of branchList should equal 3")

		var array1 = branchList.toArray()
		assertEquals(3, array1.len(), "array should have 3 items")
		assertEquals(array1[1], child1, "child1 should be at index 1")
		assertEquals(array1[2], child3, "child3 should be at index 2")
		assertEquals(array1[3], child2, "child2 should be at index 3")

		assertTrue(branchList.move(child1, child2), "branchList.move should return true if the item is moved backward")
		var array2 = branchList.toArray()
		assertEquals(3, array2.len(), "array should have 3 items")

		assertEquals(array2[1], child3, "child3 should be at index 1")
		assertEquals(array2[2], child1, "child1 should be at index 2")
		assertEquals(array2[3], child2, "child2 should be at index 3")

		assertTrue(branchList.move(child3), "branchList.move should return true if the item is moved to the end")
		var array3 = branchList.toArray()
		assertEquals(3, array3.len(), "array should have 3 items")
		assertEquals(array3[1], child1, "child1 should be at index 1")
		assertEquals(array3[2], child2, "child2 should be at index 2")
		assertEquals(array3[3], child3, "child3 should be at index 3")

		assertTrue(branchList.move(child3, child2), "branchList.move should return true if the item is moved forward")
		var array4 = branchList.toArray()
		assertEquals(3, array4.len(), "array should have 3 items")
		assertEquals(array4[1], child1, "child1 should be at index 1")
		assertEquals(array4[2], child3, "child3 should be at index 2")
		assertEquals(array4[3], child2, "child2 should be at index 3")

		assertFalse(branchList.move(child1, child1), "branchList.move should return false if the item should be moved before itself")

		assertTrue(branchList.remove(child1), "branchList.remove should return true")
		assertFalse(branchList.contains(child1), "branchList should not contain child1")
		assertFalse(branchList.remove(child1), "branchList.remove should return false if the item is not in the list")
		assertEquals(2, branchList.size(), "size of branchList should be 2")
		assertFalse(branchList.move(child1, child2), "branchList.move should return false if the item to be moved is not in the list")
		assertFalse(branchList.move(child2, child1), "branchList.move should return false if the item should be moved before an item that is not in the list")

		var selected = branchList.select(function (child) {
			return arguments.child.getId() == child2.getId()
		})
		assertEquals(selected, child2, "child2 should be selected")
		var selected = branchList.select(function (child) {
			return arguments.child.getId() == child1.getId()
		})
		assertTrue(selected == null, "selected should be null if the predicate is not met")

		branchList.remove(child2)
		branchList.remove(child3)
		assertTrue(branchList.isEmpty(), "branchList should be empty")

	}

}