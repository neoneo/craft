import craft.core.content.*;

import craft.xml.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		variables.element = new Element()
	}

	public void function Ready_Should_ReturnFalse_IfNotConstruct() {
		assertFalse(variables.element.ready(), "if no construction has taken place, ready() should return false")
	}

	public void function Ready_Should_ReturnTrue_IfProductSet() {
		makePublic(variables.element, "setProduct")

		var product = mock(CreateObject("Component"))
		variables.element.setProduct(product)

		assertSame(product, variables.element.product())
		assertTrue(variables.element.ready(), "if there is a product, ready() should return true")
	}

	public void function ParentRelationship() {
		var parent = new Element()
		variables.element.setParent(parent)
		assertTrue(variables.element.hasParent())
		assertSame(parent, variables.element.parent())
	}

	public void function ChildRelationship() {
		var child1 = new Element()
		var child2 = new Element()

		variables.element.add(child1)
		variables.element.add(child2)

		var children = variables.element.children()
		assertEquals(2, children.len())
		assertSame(child1, children[1])
		assertSame(child2, children[2])

		assertSame(variables.element, child1.parent())
		assertSame(variables.element, child2.parent())
	}

	public void function ChildrenReady_Should_ReturnCorrectBoolean() {
		assertTrue(variables.element.childrenReady(), "if there are no children, childrenReady() should return true")

		var child1 = new Element()
		makePublic(child1, "setProduct")
		var child2 = new Element()
		makePublic(child2, "setProduct")

		variables.element.add(child1)
		variables.element.add(child2)

		var children = variables.element.children()
		assertEquals(2, children.len())
		assertSame(child1, children[1])
		assertSame(child2, children[2])

		assertFalse(variables.element.childrenReady(), "if both children are not ready, childrenReady() should return false")

		var product = mock(CreateObject("Component"))
		child1.setProduct(product)
		assertTrue(child1.ready())
		assertFalse(variables.element.childrenReady(), "if one of the children is not ready, childrenReady() should return false")
		child2.setProduct(product)
		assertTrue(child2.ready())
		assertTrue(variables.element.childrenReady(), "if all children are ready, childrenReady() should return true")
	}

	public void function SiblingRelationship() {
		assertEquals(0, variables.element.siblingIndex(), "if an element has no parent, siblingIndex() should return 0")
		assertEquals(0, variables.element.siblings().len(), "if an element has no parent, siblings() should return an empty array")

		// Create children with a ref, so that .equals can distinguish them.
		var child1 = new Element(ref: "1")
		var child2 = new Element(ref: "2")
		var child3 = new Element(ref: "3")
		variables.element.add(child1)
		variables.element.add(child2)
		variables.element.add(child3)

		assertEquals(1, child1.siblingIndex())
		assertEquals([child2, child3], child1.siblings())

		assertEquals(2, child2.siblingIndex())
		assertEquals([child1, child3], child2.siblings())

		assertEquals(3, child3.siblingIndex())
		assertEquals([child1, child2], child3.siblings())
	}

}