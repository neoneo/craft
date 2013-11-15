import craft.core.util.*;

component extends="mxunit.framework.TestCase" {

	private BranchList function createBranchList(required craft.core.util.Branch parent) {
		Throw("Not implemented")
	}

	public void function setUp() {
		variables.parent = mockBranch()
		variables.branchList = createBranchList(variables.parent)
		variables.child1 = mockBranch()
		variables.child2 = mockBranch()
		variables.child3 = mockBranch()
		variables.branchList.add(variables.child1)
		variables.branchList.add(variables.child2)
		variables.branchList.add(variables.child3)
	}

	public void function AfterCreation_Should_BeEmpty() {
		var branchList = createBranchList(variables.parent)
		assertSame(variables.parent, branchList.parent(), "parent should be the object passed to the constructor")
		assertTrue(branchList.isEmpty(), "branchList should be empty after creation")
	}

	public void function Add_Should_ReturnCorrectBooleanValue() {
		var branch = mockBranch().setParent(variables.parent)
		assertTrue(variables.branchList.add(branch), "branchList.add should return true if the child is not in the list")
		branch.verify().setParent(variables.parent)
		assertFalse(variables.branchList.isEmpty(), "branchList should not be empty")
	}

	public void function Add_Should_ReturnFalse_IfHasParent() {
		var child = mock(new BranchStub()).hasParent().returns(true)
		assertFalse(branchList.add(child), "branchList.add should return false if the child has a parent")
	}

	public void function Add_Should_ReturnFalse_IfInsertedBeforeNotExists() {
		assertFalse(branchList.add(mockBranch(), mockBranch()), "branchList.add should return false if the child should be moved before a child that is not in the list")
	}

	public void function Contains_Should_ReturnCorrectBooleanValue() {
		assertTrue(variables.branchList.contains(variables.child1), "branchList.contains should return true for child1")
		assertTrue(variables.branchList.contains(variables.child2), "branchList.contains should return true for child2")
		assertTrue(variables.branchList.contains(variables.child3), "branchList.contains should return true for child3")
		assertFalse(variables.branchList.contains(new BranchStub()), "branchList.contains should return false for new branch stub")
		assertEquals(3, variables.branchList.size(), "size of branchList should equal 3")
	}

	public void function Move_Should_ReturnTrue_IfMovedBackward() {
		assertTrue(variables.branchList.move(variables.child2, variables.child1), "branchList.move should return true if the child is moved backward")
	}

	public void function Move_Should_ReturnTrue_IfMovedForward() {
		assertTrue(variables.branchList.move(variables.child3, variables.child2), "branchList.move should return true if the child is moved forward")
	}

	public void function Move_Should_ReturnTrue_IfMoveToTheEnd() {
		assertTrue(variables.branchList.move(variables.child1), "branchList.move should return true if the child is moved to the end")
	}

	public void function Move_Should_ReturnFalse_IfMovedBeforeNotExists() {
		assertFalse(variables.branchList.move(variables.child1, mockBranch()), "branchList.move should return false if the child should be moved before an item that does not exist")
	}

	public void function Move_Should_ReturnFalse_IfMovedBeforeItself() {
		assertFalse(variables.branchList.move(variables.child1, variables.child1), "branchList.move should return false if the child should be moved before itself")
	}

	public void function Move_Should_ReturnFalse_IfNotExists() {
		assertFalse(variables.branchList.move(mockBranch(), variables.child1), "branchList.move should return false if the child to be moved is not in the list")
	}

	public void function Remove_Should_ReturnTrue_IfExists() {
		assertTrue(variables.branchList.remove(variables.child1), "branchList.remove should return true if the child exists in the list")
		assertFalse(variables.branchList.contains(variables.child1), "branchList.contains should return false if the child is removed")
		assertFalse(variables.branchList.remove(variables.child1), "branchList.remove should return false if the child is removed from the list")
		assertEquals(2, branchList.size())
	}

	public void function Remove_Should_ReturnFalse_IfNotExists() {
		assertFalse(variables.branchList.remove(mockBranch()), "branchList.remove should return false if the child does not exist")
	}

	public void function ToArray_Should_ReturnCorrectOrderAfterAdd() {
		var array = variables.branchList.toArray()
		assertEquals(3, array.len(), "array should have 3 items")
		assertSame(array[1], variables.child1, "child1 should be at index 1")
		assertSame(array[2], variables.child2, "child2 should be at index 2")
		assertSame(array[3], variables.child3, "child3 should be at index 3")
	}

	public void function ToArray_Should_ReturnCorrectOrderAfterMove() {
		variables.branchList.move(variables.child2, variables.child1)
		variables.branchList.move(variables.child3, variables.child2)
		var array = variables.branchList.toArray()
		assertEquals(3, array.len(), "array should have 3 items")
		assertSame(array[1], variables.child3, "child3 should be at index 1")
		assertSame(array[2], variables.child2, "child2 should be at index 2")
		assertSame(array[3], variables.child1, "child1 should be at index 3")
	}

	public void function ToArray_Should_ReturnCorrectOrderAfterRemove() {
		variables.branchList.remove(variables.child2)
		var array = variables.branchList.toArray()
		assertEquals(2, array.len(), "array should have 2 items")
		assertSame(array[1], variables.child1, "child1 should be at index 1")
		assertSame(array[2], variables.child3, "child3 should be at index 2")
	}

	public void function Select_Should_ReturnItemThatMatches() {

		var selected = variables.branchList.select(function (child) {
			return arguments.child === variables.child1
		})
		assertSame(selected, variables.child1, "branchList.select should return child1")
		var noChild = mockBranch()
		var selected = branchList.select(function (child) {
			return arguments.child === noChild
		})
		assertTrue(IsNull(selected), "branchlist.select should return null if the predicate is not met")
	}

	private Branch function mockBranch() {
		return mock(new BranchStub()).hasParent().returns(false)
	}

}