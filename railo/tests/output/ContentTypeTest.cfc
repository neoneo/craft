component extends="mxunit.framework.TestCase" {

	public void function TXTContentType() {

		var contentType = new craft.core.output.TXTContentType()
		assertEquals("txt", contentType.getName(), "contentType.getName should return 'text'")
		assertEquals("text/plain", contentType.getMimeType(), "contentType.getMimeType should return 'text/plain'")
		assertEquals("abc", contentType.concatenate(["a", "b", "c"]), "concatenating ['a', 'b', 'c'] should return 'abc'")
		assertEquals("abc", contentType.write("abc"), "writing 'abc' should return 'abc'")

		fallbacks(contentType)

	}

	public void function HTMLContentType() {

		var contentType = new craft.core.output.HTMLContentType()
		assertEquals("html", contentType.getName(), "contentType.getName should return 'html'")
		assertEquals("text/html", contentType.getMimeType(), "contentType.getMimeType should return 'text/html'")
		assertEquals("abc", contentType.concatenate(["a", "b", "c"]), "concatenating ['a', 'b', 'c'] should return 'abc'")
		assertEquals("abc", contentType.write("abc"), "writing 'abc' should return 'abc'")

		fallbacks(contentType)

	}

	public void function JSONContentType() {

		var contentType = new craft.core.output.JSONContentType()
		assertEquals("json", contentType.getName(), "contentType.getName should return 'json'")
		assertEquals("application/json", contentType.getMimeType(), "contentType.getMimeType should return 'application/json'")

		var result = contentType.concatenate(["string1", "string2 with ""quotes"""])
		assertEquals('"string1","string2 with \"quotes\""', result, "the result should return the original strings, possibly modified to conform to JSON")

		var object1 = SerializeJSON({"a" = 1, "b" = 2})
		var object2 = SerializeJSON({"c" = 3, "d" = 4})
		var result = contentType.concatenate([object1, object2])
		assertEquals(object1 & "," & object2, result, "if multiple JSON strings are passed in, the result should return the strings unaltered")

		var string1 = "a"
		var result = contentType.concatenate([string1])
		assertEquals('"a"', result, "if a single non-JSON string is passed in, the result should return the string quoted")

		var result = contentType.concatenate([object1])
		assertEquals(object1, result, "if a single JSON string is passed in, the result should equal the string unaltered")

		var result = contentType.concatenate([object1, "["])
		assertEquals(object1 & "," & '"["', result, "if multiple strings are passed in, the result should contain JSON strings unaltered, and other strings quoted")

		assertEquals("[1,2,3]", contentType.write("[1,2,3]"), "when writing valid JSON, the result should equal the input")

		try {
			contentType.write("a")
		} catch (any e) {
			assertEquals("IllegalContentException", e.type, "when writing invalid JSON, exception 'IllegalContentException' should be thrown")
		}

		fallbacks(contentType)

	}

	public void function XMLContentType() {

		var contentType = new craft.core.output.XMLContentType()
		assertEquals("xml", contentType.getName(), "contentType.getName should return 'xml'")
		assertEquals("application/xml", contentType.getMimeType(), "contentType.getMimeType should return 'application/xml'")

		var result = contentType.concatenate(['<node1 />', '<node2 />'])
		assertEquals('<node1 /><node2 />', result, "concatenating '<node1 />' and '<node2 />' should return '<node1 /><node2 />'")

		var result = contentType.concatenate(['<node1 />', '<'])
		assertEquals('<node1 /><![CDATA[<]]>', result, "non-XML strings with reserved characters should be wrapped in a CDATA section")

		assertEquals('<node1 />', contentType.write('<node1 />', "when writing valid XML, the result should equal the input"))
		try {
			contentType.write('<node1>')
			fail("when writing invalid XML, an exception should be thrown")
		} catch (any e) {
			assertEquals("IllegalContentException", e.type, "when writing invalid XML, exception 'IllegalContentException' should be thrown")
		}

		fallbacks(contentType)

	}

	public void function PDFContentType() {

		var contentType = new craft.core.output.PDFContentType()
		assertEquals("pdf", contentType.getName(), "contentType.getName should return 'pdf'")
		assertEquals("application/pdf", contentType.getMimeType(), "contentType.getMimeType should return 'application/pdf'")
		assertEquals("abc", contentType.concatenate(["a", "b", "c"]), "concatenating ['a', 'b', 'c'] should return 'abc'")
		assertTrue(IsPDFObject(contentType.write("abc")), "writing 'abc' should return PDF")

		fallbacks(contentType)

	}

	private void function fallbacks(required craft.core.output.ContentType contentType) {

		var ext1 = new ContentTypeStub("ext1")
		var ext2 = new ContentTypeStub("ext2")

		arguments.contentType.addFallback(ext1)
		var array1 = arguments.contentType.getFallbacks()
		assertEquals(1, array1.len(), "after adding one fallback contentType, getFallBacks should return an array of 1 element")

		arguments.contentType.addFallback(ext2)
		var array2 = arguments.contentType.getFallbacks()
		assertEquals(2, array2.len(), "after adding two fallback extensions, getFallBacks should return an array of 2 elements")
		assertEquals(ext1, array2[1], "ext1 should be the first fallback")
		assertEquals(ext2, array2[2], "ext2 should be the second fallback")

		arguments.contentType.removeFallback(ext1)
		var array3 = arguments.contentType.getFallbacks()
		assertEquals(1, array3.len(), "after removing one fallback contentType, getFallBacks should return an array of 1 element")
		assertEquals(ext2, array3[1], "ext2 should be the first fallback")

		var class = GetMetaData(arguments.contentType).name
		var ext3 = new "#class#"()
		arguments.contentType.addFallback(ext3)
		var array4 = arguments.contentType.getFallbacks()
		assertEquals(1, array4.len(), "after adding an instance of itself as a fallback, getFallBacks should return an array of 1 element")
		assertEquals(ext2, array4[1], "ext2 should be the first fallback")


	}

}