component extends="mxunit.framework.TestCase" {

	public void function ViewInventory() {

		var viewInventory = new craft.core.output.ViewInventory("cfm")

		var ext1 = new ExtensionStub("ext1")
		var ext2 = new ExtensionStub("ext2")
		var ext3 = new ExtensionStub("ext3")

		ext1.addFallback(ext2)
		ext1.addFallback(ext3)

		viewInventory.addMapping("/craft/../tests/output/viewstubs/dir1")

		var result = viewInventory.get("view1", ext1) // OK
		assertTrue(result.template.endsWith("/dir1/view1.ext1.cfm"), "template view1.ext1.cfm should be found in dir1");

		var result = viewInventory.get("view2", ext1) // OK: fallback to view2.ext2
		assertTrue(result.template.endsWith("/dir1/view2.ext2.cfm"), "template view2.ext1.cfm should fall back to view2.ext2.cfm in dir1");

		var result = viewInventory.get("view3", ext1) // OK: fallback to view3.ext3
		assertTrue(result.template.endsWith("/dir1/view3.ext3.cfm"), "template view3.ext1.cfm should fall back to view3.ext3.cfm in dir1");

		try {
			var result = viewInventory.get("view3", ext2) // error: ext2 has no fallbacks
			fail("view3.ext2.cfm should not be found")
		} catch (any e) {
			assertEquals("craft.core.output.ViewNotFoundException", e.type, "when a view is not found, exception 'craft.core.output.ViewNotFoundException' should be thrown")
		}

		viewInventory.addMapping("/craft/../tests/output/viewstubs/dir2")

		var result = viewInventory.get("view2", ext2) // OK: from dir1
		assertTrue(result.template.endsWith("/dir1/view2.ext2.cfm"), "template view2.ext2.cfm should be found in dir1");

		var result = viewInventory.get("view3", ext2) // OK: from dir2
		assertTrue(result.template.endsWith("/dir2/view3.ext2.cfm"), "template view3.ext2.cfm should be found in dir2");

	}


}