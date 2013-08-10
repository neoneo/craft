component extends="mxunit.framework.TestCase" {

	public void function TXTExtension() {

		var extension = new craft.core.output.TXTExtension()
		assertEquals("txt", extension.getName(), "extension.getName should return 'text'")
		assertEquals("text/plain", extension.getMimeType(), "extension.getMimeType should return 'text/plain'")
		assertEquals("abc", extension.concatenate(["a", "b", "c"]), "concatenating ['a', 'b', 'c'] should return 'abc'")
		assertEquals("abc", extension.write("abc"), "writing 'abc' should return 'abc'")

		fallbacks(extension)

	}

	public void function HTMLExtension() {

		var extension = new craft.core.output.HTMLExtension()
		assertEquals("html", extension.getName(), "extension.getName should return 'html'")
		assertEquals("text/html", extension.getMimeType(), "extension.getMimeType should return 'text/html'")
		assertEquals("abc", extension.concatenate(["a", "b", "c"]), "concatenating ['a', 'b', 'c'] should return 'abc'")
		assertEquals("abc", extension.write("abc"), "writing 'abc' should return 'abc'")

		fallbacks(extension)

	}

	public void function JSONExtension() {

		var extension = new craft.core.output.JSONExtension()
		assertEquals("json", extension.getName(), "extension.getName should return 'json'")
		assertEquals("application/json", extension.getMimeType(), "extension.getMimeType should return 'application/json'")

		var result = extension.concatenate(["string1", "string2 with ""quotes"""])
		assertEquals('"string1","string2 with \"quotes\""', result, "the result should return the original strings, possibly modified to conform to JSON")

		var object1 = SerializeJSON({"a" = 1, "b" = 2})
		var object2 = SerializeJSON({"c" = 3, "d" = 4})
		var result = extension.concatenate([object1, object2])
		assertEquals(object1 & "," & object2, result, "if multiple JSON strings are passed in, the result should return the strings unaltered")

		var string1 = "a"
		var result = extension.concatenate([string1])
		assertEquals('"a"', result, "if a single non-JSON string is passed in, the result should return the string quoted")

		var result = extension.concatenate([object1])
		assertEquals(object1, result, "if a single JSON string is passed in, the result should equal the string unaltered")

		var result = extension.concatenate([object1, "["])
		assertEquals(object1 & "," & '"["', result, "if multiple strings are passed in, the result should contain JSON strings unaltered, and other strings quoted")

		assertEquals("[1,2,3]", extension.write("[1,2,3]"), "when writing valid JSON, the result should equal the input")

		try {
			extension.write("a")
		} catch (any e) {
			assertEquals("IllegalContentException", e.type, "when writing invalid JSON, exception 'IllegalContentException' should be thrown")
		}

		fallbacks(extension)

	}

	public void function XMLExtension() {

		var extension = new craft.core.output.XMLExtension()
		assertEquals("xml", extension.getName(), "extension.getName should return 'xml'")
		assertEquals("application/xml", extension.getMimeType(), "extension.getMimeType should return 'application/xml'")

		var result = extension.concatenate(['<node1 />', '<node2 />'])
		assertEquals('<node1 /><node2 />', result, "concatenating '<node1 />' and '<node2 />' should return '<node1 /><node2 />'")

		var result = extension.concatenate(['<node1 />', '<'])
		assertEquals('<node1 /><![CDATA[<]]>', result, "non-XML strings with reserved characters should be wrapped in a CDATA section")

		assertEquals('<node1 />', extension.write('<node1 />', "when writing valid XML, the result should equal the input"))
		try {
			extension.write('<node1>')
			fail("when writing invalid XML, an exception should be thrown")
		} catch (any e) {
			assertEquals("IllegalContentException", e.type, "when writing invalid XML, exception 'IllegalContentException' should be thrown")
		}

		fallbacks(extension)

	}

	public void function PDFExtension() {

		var extension = new craft.core.output.PDFExtension()
		assertEquals("pdf", extension.getName(), "extension.getName should return 'pdf'")
		assertEquals("application/pdf", extension.getMimeType(), "extension.getMimeType should return 'application/pdf'")
		assertEquals("abc", extension.concatenate(["a", "b", "c"]), "concatenating ['a', 'b', 'c'] should return 'abc'")
		assertTrue(IsPDFObject(extension.write("abc")), "writing 'abc' should return PDF")

		fallbacks(extension)

	}

	private void function fallbacks(required craft.core.output.Extension extension) {

		var ext1 = new ExtensionStub("ext1")
		var ext2 = new ExtensionStub("ext2")

		arguments.extension.addFallback(ext1)
		var array1 = arguments.extension.getFallbacks()
		assertEquals(1, array1.len(), "after adding one fallback extension, getFallBacks should return an array of 1 element")

		arguments.extension.addFallback(ext2)
		var array2 = arguments.extension.getFallbacks()
		assertEquals(2, array2.len(), "after adding two fallback extensions, getFallBacks should return an array of 2 elements")
		assertEquals(ext1, array2[1], "ext1 should be the first fallback")
		assertEquals(ext2, array2[2], "ext2 should be the second fallback")

		arguments.extension.removeFallback(ext1)
		var array3 = arguments.extension.getFallbacks()
		assertEquals(1, array3.len(), "after removing one fallback extension, getFallBacks should return an array of 1 element")
		assertEquals(ext2, array3[1], "ext2 should be the first fallback")

		var class = GetMetaData(arguments.extension).name
		var ext3 = new "#class#"()
		arguments.extension.addFallback(ext3)
		var array4 = arguments.extension.getFallbacks()
		assertEquals(1, array4.len(), "after adding an instance of itself as a fallback, getFallBacks should return an array of 1 element")
		assertEquals(ext2, array4[1], "ext2 should be the first fallback")


	}

}