import craft.core.output.*;

component extends="mxunit.framework.TestCase" {

	public void function TXTContentType() {
		var contentType = new TXTContentType()
		assertEquals("txt", contentType.name())
		assertEquals("text/plain", contentType.mimeType())
		assertEquals("abc", contentType.merge(["a", "b", "c"]))
		assertEquals("abc", contentType.write("abc"))
	}

	public void function HTMLContentType() {
		var contentType = new HTMLContentType()
		assertEquals("html", contentType.name())
		assertEquals("text/html", contentType.mimeType())
		assertEquals("abc", contentType.merge(["a", "b", "c"]))
		assertEquals("abc", contentType.write("abc"))
	}

	public void function JSONContentType() {
		var contentType = new JSONContentType()
		assertEquals("json", contentType.name())
		assertEquals("application/json", contentType.mimeType())

		var result = contentType.merge(["string1", "string2 with ""quotes"""])
		assertEquals('"string1","string2 with \"quotes\""', result, "the result should return the original strings, possibly modified to conform to JSON")

		var object1 = SerializeJSON({"a" = 1, "b" = 2})
		var object2 = SerializeJSON({"c" = 3, "d" = 4})
		var result = contentType.merge([object1, object2])
		assertEquals(object1 & "," & object2, result, "if multiple JSON strings are passed in, the result should return the strings unaltered")

		var string1 = "a"
		var result = contentType.merge([string1])
		assertEquals('"a"', result, "if a single non-JSON string is passed in, the result should return the string quoted")

		var result = contentType.merge([object1])
		assertEquals(object1, result, "if a single JSON string is passed in, the result should equal the string unaltered")

		var result = contentType.merge([object1, "["])
		assertEquals(object1 & "," & '"["', result, "if multiple strings are passed in, the result should contain JSON strings unaltered, and other strings quoted")

		assertEquals("[1,2,3]", contentType.write("[1,2,3]"), "when writing valid JSON, the result should equal the input")

		try {
			contentType.write("a")
			fail("when writing invalid JSON, an exception should be thrown")
		} catch (any e) {
			assertEquals("IllegalContentException", e.type, "when writing invalid JSON, exception 'IllegalContentException' should be thrown")
		}
	}

	public void function XMLContentType() {

		var contentType = new XMLContentType()
		assertEquals("xml", contentType.name())
		assertEquals("application/xml", contentType.mimeType())

		var result = contentType.merge(['<node1 />', '<node2 />'])
		assertEquals('<node1 /><node2 />', result)

		var result = contentType.merge(['<node1 />', '<'])
		assertEquals('<node1 /><![CDATA[<]]>', result, "non-XML strings with reserved characters should be wrapped in a CDATA section")

		assertEquals('<node1 />', contentType.write('<node1 />', "when writing valid XML, the result should equal the input"))
		try {
			contentType.write('<node1>')
			fail("when writing invalid XML, an exception should be thrown")
		} catch (any e) {
			assertEquals("IllegalContentException", e.type, "when writing invalid XML, exception 'IllegalContentException' should be thrown")
		}
	}

	public void function PDFContentType() {
		var contentType = new PDFContentType()
		assertEquals("pdf", contentType.name())
		assertEquals("application/pdf", contentType.mimeType())
		assertEquals("abc", contentType.merge(["a", "b", "c"]))
		assertTrue(IsPDFObject(contentType.write("abc")), "writing 'abc' should return PDF")
	}

}