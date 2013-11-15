import craft.core.output.*;

component extends="mxunit.framework.TestCase" {

	public void function TXTContentType() {

		var contentType = new TXTContentType()
		assertEquals("txt", contentType.name(), "contentType.name should return 'text'")
		assertEquals("text/plain", contentType.mimeType(), "contentType.mimeType should return 'text/plain'")
		assertEquals("abc", contentType.convert(["a", "b", "c"]), "concatenating ['a', 'b', 'c'] should return 'abc'")
		assertEquals("abc", contentType.write("abc"), "writing 'abc' should return 'abc'")

		fallbacks(contentType)

	}

	public void function HTMLContentType() {

		var contentType = new HTMLContentType()
		assertEquals("html", contentType.name(), "contentType.name should return 'html'")
		assertEquals("text/html", contentType.mimeType(), "contentType.mimeType should return 'text/html'")
		assertEquals("abc", contentType.convert(["a", "b", "c"]), "concatenating ['a', 'b', 'c'] should return 'abc'")
		assertEquals("abc", contentType.write("abc"), "writing 'abc' should return 'abc'")

		fallbacks(contentType)

	}

	public void function JSONContentType() {

		var contentType = new JSONContentType()
		assertEquals("json", contentType.name(), "contentType.name should return 'json'")
		assertEquals("application/json", contentType.mimeType(), "contentType.mimeType should return 'application/json'")

		var result = contentType.convert(["string1", "string2 with ""quotes"""])
		assertEquals('"string1","string2 with \"quotes\""', result, "the result should return the original strings, possibly modified to conform to JSON")

		var object1 = SerializeJSON({"a" = 1, "b" = 2})
		var object2 = SerializeJSON({"c" = 3, "d" = 4})
		var result = contentType.convert([object1, object2])
		assertEquals(object1 & "," & object2, result, "if multiple JSON strings are passed in, the result should return the strings unaltered")

		var string1 = "a"
		var result = contentType.convert([string1])
		assertEquals('"a"', result, "if a single non-JSON string is passed in, the result should return the string quoted")

		var result = contentType.convert([object1])
		assertEquals(object1, result, "if a single JSON string is passed in, the result should equal the string unaltered")

		var result = contentType.convert([object1, "["])
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

		var contentType = new XMLContentType()
		assertEquals("xml", contentType.name(), "contentType.name should return 'xml'")
		assertEquals("application/xml", contentType.mimeType(), "contentType.mimeType should return 'application/xml'")

		var result = contentType.convert(['<node1 />', '<node2 />'])
		assertEquals('<node1 /><node2 />', result, "concatenating '<node1 />' and '<node2 />' should return '<node1 /><node2 />'")

		var result = contentType.convert(['<node1 />', '<'])
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

		var contentType = new PDFContentType()
		assertEquals("pdf", contentType.name(), "contentType.name should return 'pdf'")
		assertEquals("application/pdf", contentType.mimeType(), "contentType.mimeType should return 'application/pdf'")
		assertEquals("abc", contentType.convert(["a", "b", "c"]), "concatenating ['a', 'b', 'c'] should return 'abc'")
		assertTrue(IsPDFObject(contentType.write("abc")), "writing 'abc' should return PDF")

		fallbacks(contentType)

	}

	private void function fallbacks(required ContentType contentType) {

		var ext1 = mock(CreateObject("ContentType")).name().returns("ext1")
		var ext2 = mock(CreateObject("ContentType")).name().returns("ext2")

		arguments.contentType.addFallback(ext1)
		var array1 = arguments.contentType.fallbacks()
		assertEquals(1, array1.len(), "after adding one fallback content type, fallBacks should return an array of 1 element")
		assertSame(ext1, array1[1])

		arguments.contentType.addFallback(ext1)
		var array2 = arguments.contentType.fallbacks()
		assertEquals(1, array2.len(), "adding the same fallback a second time should be ignored")

		arguments.contentType.addFallback(ext2)
		var array3 = arguments.contentType.fallbacks()
		assertEquals(2, array3.len(), "after adding two fallback content types, fallBacks should return an array of 2 elements")
		assertSame(ext1, array3[1], "ext1 should be the first fallback")
		assertSame(ext2, array3[2], "ext2 should be the second fallback")

		arguments.contentType.removeFallback(ext1)
		var array4 = arguments.contentType.fallbacks()
		assertEquals(1, array4.len(), "after removing one fallback content type, fallBacks should return an array of 1 element")
		assertSame(ext2, array4[1], "ext2 should be the only remaining fallback")

		var class = GetMetaData(arguments.contentType).name
		var ext3 = new "#class#"()
		arguments.contentType.addFallback(ext3)
		var array5 = arguments.contentType.fallbacks()
		assertEquals(1, array5.len(), "adding an instance of the same class as a fallback should be ignored")
		assertSame(ext2, array5[1], "ext2 should still be the only fallback")


	}

}