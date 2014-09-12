import craft.content.*;

import craft.markup.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		this.contentFactory = mock(CreateObject("ContentFactory"))
		this.element = new Element(this.contentFactory)
	}

	public void function Ready_Should_ReturnFalse_IfNotConstructed() {
		assertFalse(this.element.ready, "if no construction has taken place, ready should return false")
	}

	public void function Attributes_Should_BeSet_When_Constructed() {
		var element = new stubs.ElementStub(this.contentFactory, {
			ref: "ref",
			someBoolean: true,
			someDate: CreateDate(2000, 1, 1),
			someNumber: 42
		})

		assertEquals("ref", element.ref)
		assertEquals(true, element.someBoolean)
		assertEquals(CreateDate(2000, 1, 1), element.someDate)
		assertEquals(42, element.someNumber)
	}

	public void function Ready_Should_ReturnTrue_IfProductSet() {
		var product = mock(CreateObject("Component"))
		this.element.product = product

		assertTrue(this.element.ready, "if there is a product, ready should return true")
	}

	public void function ParentRelationship() {
		var parent = new Element(this.contentFactory)
		this.element.parent = parent
		assertTrue(this.element.hasParent)
		assertSame(parent, this.element.parent)
	}

	public void function ChildRelationship() {
		assertFalse(this.element.hasChildren)

		var child1 = new Element(this.contentFactory)
		var child2 = new Element(this.contentFactory)

		this.element.add(child1)
		this.element.add(child2)

		assertTrue(this.element.hasChildren)

		var children = this.element.children
		assertEquals(2, children.len())
		assertSame(child1, children[1])
		assertSame(child2, children[2])

		assertSame(this.element, child1.parent)
		assertSame(this.element, child2.parent)
	}

	public void function ChildrenReady_Should_ReturnCorrectBoolean() {
		assertTrue(this.element.getChildrenReady(), "if there are no children, childrenReady should return true")

		var child1 = new Element(this.contentFactory)
		var child2 = new Element(this.contentFactory)

		this.element.add(child1)
		this.element.add(child2)

		var children = this.element.children
		assertEquals(2, children.len())
		assertSame(child1, children[1])
		assertSame(child2, children[2])

		assertFalse(this.element.childrenReady, "if both children are not ready, childrenReady should return false")

		var product = mock(CreateObject("Component"))
		child1.product = product
		assertTrue(child1.getReady())
		assertFalse(this.element.getChildrenReady(), "if one of the children is not ready, childrenReady should return false")
		child2.product = product
		assertTrue(child2.getReady())
		assertTrue(this.element.getChildrenReady(), "if all children are ready, childrenReady should return true")
	}

	public void function SiblingRelationship() {
		assertEquals(0, this.element.siblingIndex, "if an element has no parent, siblingIndex should return 0")
		assertTrue(this.element.siblings.isEmpty(), "if an element has no parent, siblings should return an empty array")

		// Create children with a ref, so that .equals can distinguish them.
		var child1 = new Element(this.contentFactory, {ref: "1"})
		var child2 = new Element(this.contentFactory, {ref: "2"})
		var child3 = new Element(this.contentFactory, {ref: "3"})
		this.element.add(child1)
		this.element.add(child2)
		this.element.add(child3)

		assertEquals(1, child1.siblingIndex)
		assertSameItems([child2, child3], child1.siblings)

		assertEquals(2, child2.siblingIndex)
		assertSameItems([child1, child3], child2.siblings)

		assertEquals(3, child3.siblingIndex)
		assertSameItems([child1, child2], child3.siblings)
	}

	private void function assertSameItems(required Array expected, required Array actual) {
		assertEquals(arguments.expected.len(), arguments.actual.len())

		var actual = arguments.actual
		var same = arguments.expected.every(function (item, index) {
			return arguments.item === actual[index];
		})
		assertTrue(same)
	}

}