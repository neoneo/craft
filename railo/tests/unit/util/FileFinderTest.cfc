import craft.util.*;

component extends="mxunit.framework.TestCase" {

	this.mapping = "/crafttests/unit/util/files"

	public void function setUp(){
		this.fileFinder = new FileFinder("txt")
	}

	public void function Get_Should_ReturnFileName_When_FileExists() {
		this.fileFinder.addMapping(this.mapping & "/dir1")
		var file = this.fileFinder.get("file1") // OK
		assertTrue(file.endsWith("/dir1/file1.txt"), "file1.txt should be found in dir1")
	}

	public void function Get_Should_ThrowFileNotFound_When_NoMappingAvailable() {
		// We don't add a mapping, but still try to find some file.
		try {
			var file = this.fileFinder.get("file") // error: file does not exist
			fail("exception should have been thrown")
		} catch (FileNotFoundException e) {}
	}

	public void function Get_Should_ThrowFileNotFound_When_FileDoesNotExist() {
		this.fileFinder.addMapping(this.mapping & "/dir1")
		try {
			var file = this.fileFinder.get("file3") // error: file does not exist
			fail("file3.txt should not be found in dir1")
		} catch (FileNotFoundException e) {}
	}

	public void function Get_Should_SearchMappingsInOrder() {
		this.fileFinder.addMapping(this.mapping & "/dir1")
		this.fileFinder.addMapping(this.mapping & "/dir2")
		this.fileFinder.addMapping(this.mapping & "/dir3")

		var file = this.fileFinder.get("file1") // OK: from dir1
		assertTrue(file.endsWith("/dir1/file1.txt"), "file1.txt should be found in dir1")

		var file = this.fileFinder.get("file2") // OK: from dir1 (also exists in dir2)
		assertTrue(file.endsWith("/dir1/file2.txt"), "file2.txt should be found in dir1")

		var file = this.fileFinder.get("file3") // OK: from dir2 (also exists in dir3)
		assertTrue(file.endsWith("/dir2/file3.txt"), "file3.txt should be found in dir2")

		var file = this.fileFinder.get("file4") // OK: from dir3
		assertTrue(file.endsWith("/dir3/file4.txt"), "file4.txt should be found in dir3")
	}

	public void function RemoveMapping_ShouldNot_SearchRemovedMapping() {
		this.fileFinder.addMapping(this.mapping & "/dir1")
		this.fileFinder.addMapping(this.mapping & "/dir2")
		this.fileFinder.get("file1") // from dir1
		this.fileFinder.get("file2") // from dir1

		this.fileFinder.removeMapping(this.mapping & "/dir1")

		var file = this.fileFinder.get("file2") // now from dir2
		assertTrue(file.endsWith("/dir2/file2.txt"), "file2.txt should be found in dir2")

		try {
			var file = this.fileFinder.get("file1") // error: file does not exist in dir2
			fail("file1.txt should not be found")
		} catch (FileNotFoundException e) {}
	}

}