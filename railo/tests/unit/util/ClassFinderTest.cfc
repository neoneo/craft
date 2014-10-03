import craft.util.*;

component extends="mxunit.framework.TestCase" {

	this.mapping = "/crafttests/unit/util/classes"
	this.dotMapping = "crafttests.unit.util.classes"

	public void function setUp(){
		this.classFinder = new ClassFinder()
	}


	public void function Get_Should_ReturnClass_When_ClassExists() {
		this.classFinder.addMapping(this.mapping & "/package1")

		var class = this.classFinder.get("Class1")

		assertEquals(this.dotMapping & ".package1.Class1", class)
	}

	public void function Get_Should_ReturnClass_When_ClassExistsDotDelimited() {
		this.classFinder.addMapping(this.mapping)

		var class = this.classFinder.get("package1/Class1")

		assertEquals(this.dotMapping & ".package1.Class1", class)
	}

	public void function Get_Should_ReturnClass_When_ClassExistsSlashDelimited() {
		this.classFinder.addMapping(this.mapping)

		var viewName = "/package1/Class1"
		var class = this.classFinder.get(viewName)

		assertEquals(this.dotMapping & ".package1.Class1", class)
	}

	public void function Get_Should_ThrowFileNotFoundException_When_ClassNotFound() {
		this.classFinder.addMapping(this.mapping & "/package1")
		var className = "NoClass1"

		try {
			var class = this.classFinder.get(className)
			fail("exception should have been thrown")
		} catch (FileNotFoundException e) {}
	}

	public void function Get_Should_SearchMappingsInOrder() {
		this.classFinder.addMapping(this.mapping & "/package1")
		this.classFinder.addMapping(this.mapping & "/package2")

		var class1 = this.classFinder.get("Class1")
		assertEquals(this.dotMapping & ".package1.Class1", class1)

		var class2 = this.classFinder.get("Class2")
		assertEquals(this.dotMapping & ".package1.Class2", class2)

		var class3 = this.classFinder.get("Class3")
		assertEquals(this.dotMapping & ".package2.Class3", class3)
	}

	public void function RemoveMapping_ShouldNot_SearchRemovedMapping() {
		this.classFinder.addMapping(this.mapping & "/package1")
		this.classFinder.addMapping(this.mapping & "/package2")
		this.classFinder.get("Class1") // from package1
		this.classFinder.get("Class2") // from package1

		this.classFinder.removeMapping(this.mapping & "/package1")

		var class = this.classFinder.get("Class2") // now from package2
		assertEquals(this.dotMapping & ".package2.Class2", class, "Class2 should be found in package2")

		try {
			this.classFinder.get("Class1") // error: file does not exist in dir2
			fail("Class1 should not be found")
		} catch (FileNotFoundException e) {}
	}



}