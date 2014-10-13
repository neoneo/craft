import craft.util.*;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		this.objectHelper = new ObjectHelper()
	}

	public void function MethodExistsForExplicitMethod_When_NoInheritance() {
		var metadata = GetComponentMetadata("classes.BaseClass")

		// Public method:
		assertTrue(this.objectHelper.methodExists(metadata, "publicMethod", "public"))
		// The method is public, so is also accessible if we have private or package access to the class.
		assertTrue(this.objectHelper.methodExists(metadata, "publicMethod", "package"))
		assertTrue(this.objectHelper.methodExists(metadata, "publicMethod", "private"))
		// But remote access is not allowed.
		assertFalse(this.objectHelper.methodExists(metadata, "publicMethod", "remote"))

		// Private method:
		assertTrue(this.objectHelper.methodExists(metadata, "privateMethod", "private"))
		// None of the other access levels would allow execution of the method.
		assertFalse(this.objectHelper.methodExists(metadata, "privateMethod", "package"))
		assertFalse(this.objectHelper.methodExists(metadata, "privateMethod", "public"))
		assertFalse(this.objectHelper.methodExists(metadata, "privateMethod", "remote"))

		// Non-existing method:
		assertFalse(this.objectHelper.methodExists(metadata, "nonExistingMethod", "private"))
	}

	public void function MethodExistsForGeneratedMethod_When_NoInheritance() {
		var metadata = GetComponentMetadata("classes.BaseClass")

		assertTrue(this.objectHelper.methodExists(metadata, "getProperty1", "public"))
		assertTrue(this.objectHelper.methodExists(metadata, "getProperty1", "package"))
		assertTrue(this.objectHelper.methodExists(metadata, "getProperty1", "private"))
		assertFalse(this.objectHelper.methodExists(metadata, "getProperty1", "remote"))

		// There is no setter for property2.
		assertFalse(this.objectHelper.methodExists(metadata, "setProperty2", "private"))
	}

	public void function MethodExistsForExplicitMethod_When_Inheritance() {
		var metadata = GetComponentMetadata("classes.SubSubClass")

		// publicMethod is now private (due to SubClass)
		assertTrue(this.objectHelper.methodExists(metadata, "publicMethod", "private"))
		assertFalse(this.objectHelper.methodExists(metadata, "publicMethod", "package"))
		assertFalse(this.objectHelper.methodExists(metadata, "publicMethod", "public"))
		assertFalse(this.objectHelper.methodExists(metadata, "publicMethod", "remote"))

		// Package and remote methods:
		assertTrue(this.objectHelper.methodExists(metadata, "packageMethod", "private"))
		assertTrue(this.objectHelper.methodExists(metadata, "packageMethod", "package"))
		assertFalse(this.objectHelper.methodExists(metadata, "packageMethod", "public"))
		assertFalse(this.objectHelper.methodExists(metadata, "packageMethod", "remote"))

		assertTrue(this.objectHelper.methodExists(metadata, "remoteMethod", "private"))
		assertTrue(this.objectHelper.methodExists(metadata, "remoteMethod", "package"))
		assertTrue(this.objectHelper.methodExists(metadata, "remoteMethod", "public"))
		assertTrue(this.objectHelper.methodExists(metadata, "remoteMethod", "remote"))

		// Non-existing method:
		assertFalse(this.objectHelper.methodExists(metadata, "nonExistingMethod", "private"))
	}

	public void function MethodExistsForGeneratedMethod_When_Inheritance() {
		var metadata = GetComponentMetadata("classes.SubSubClass")

		assertTrue(this.objectHelper.methodExists(metadata, "getProperty1", "public"))
		assertTrue(this.objectHelper.methodExists(metadata, "getProperty1", "package"))
		assertTrue(this.objectHelper.methodExists(metadata, "getProperty1", "private"))
		assertFalse(this.objectHelper.methodExists(metadata, "getProperty1", "remote"))

		// The setter for property2 should now exist.
		assertTrue(this.objectHelper.methodExists(metadata, "setProperty2", "private"))
	}

	public void function Extends() {
		var metadata = GetComponentMetadata("classes.BaseClass")
		var submetadata = GetComponentMetadata("classes.SubClass")
		var subsubmetadata = GetComponentMetadata("classes.SubSubClass")

		assertTrue(this.objectHelper.extends(metadata, metadata.name))
		assertTrue(this.objectHelper.extends(submetadata, metadata.name))
		assertTrue(this.objectHelper.extends(subsubmetadata, metadata.name))
		assertTrue(this.objectHelper.extends(subsubmetadata, submetadata.name))
	}

	public void function InitializeNoConstructor() {
		// The base class has no constructor, and two properties of which one has a setter.
		var base = CreateObject("classes.BaseClass")

		this.objectHelper.initialize(base, {property1: "property1", property2: "property2"})

		assertEquals("property1", base.property1)
		assertTrue(base.property2 === null) // There is no setter for property2.
	}

	public void function InitializePublicConstructor() {
		// The sub class has a public constructor that sets property3. The other properties should not be set.
		var sub = CreateObject("classes.SubClass")

		this.objectHelper.initialize(sub, {property1: "property1", property2: "property2", property3: "property3"})

		assertTrue(sub.property1 === null)
		assertTrue(sub.property2 === null)
		assertEquals("property3", sub.property3)
	}

	public void function InitializePrivateConstructor() {
		// The sub sub class has a private constructor. All 4 properties have setters.
		var subsub = CreateObject("classes.SubSubClass")

		this.objectHelper.initialize(subsub, {property1: "property1", property2: "property2", property3: "property3", property4: "property4"})

		assertEquals("property1", subsub.property1)
		assertEquals("property2", subsub.property2)
		assertEquals("property3", subsub.property3)
		assertEquals("property4", subsub.property4)
	}

	public void function CollectProperties() {
		var metadata = GetComponentMetadata("classes.SubSubClass")
		var properties = this.objectHelper.collectProperties(metadata)

		// The properties are returned in the order of definition, from subclass to superclass
		assertEquals([
			{name: "property2", type: "String", setter: "yes", default: "property"},
			{name: "property4", type: "String"},
			{name: "property3", type: "String"},
			{name: "property1", type: "String"}
		], properties)
	}

}