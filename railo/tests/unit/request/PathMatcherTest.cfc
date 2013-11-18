import craft.core.request.EntirePathMatcher;
import craft.core.request.FixedPathMatcher;
import craft.core.request.PatternPathMatcher;
import craft.core.request.RemainingPathMatcher;
import craft.core.request.RootPathMatcher;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		variables.path1 = ["dir1", "dir2", "dir3"]
		variables.path2 = ["dirA"]
	}

	public void function Entire() {
		var pathMatcher = new EntirePathMatcher()
		assertEquals(variables.path1.len(), pathMatcher.match(variables.path1))
		assertEquals(variables.path2.len(), pathMatcher.match(variables.path2))
	}

	public void function Fixed() {
		var pathMatcher = new FixedPathMatcher("dir1")

		assertEquals(1, pathMatcher.match(variables.path1))
		assertEquals(0, pathMatcher.match(variables.path2))
	}

	public void function Pattern() {
		var pathMatcher = new PatternPathMatcher("dir[0-9]")
		assertEquals(1, pathMatcher.match(variables.path1))
		assertEquals(0, pathMatcher.match(variables.path2))
		var path = ["dir10"]
		assertEquals(0, pathMatcher.match(path), "pattern path matcher should match against the complete segment")
	}

	public void function Remaining() {
		var stub = mock(CreateObject("PathMatcherStub"))
			.match(variables.path1).returns(1)
			.match(variables.path2).returns(1)
		var pathMatcher = new RemainingPathMatcher(stub)
		assertEquals(variables.path1.len(), pathMatcher.match(variables.path1), "remaining path matcher should match the complete path if the decorated path matcher matches")
		assertEquals(variables.path2.len(), pathMatcher.match(variables.path2), "remaining path matcher should match the complete path if the decorated path matcher matches")

		var stub = mock(CreateObject("PathMatcherStub"))
			.match(variables.path1).returns(0)
			.match(variables.path2).returns(0)
		var pathMatcher = new RemainingPathMatcher(stub)
		assertEquals(0, pathMatcher.match(variables.path1), "remaining path matcher should not match if the decorated path matcher does not match")
		assertEquals(0, pathMatcher.match(variables.path2), "remaining path matcher should not match if the decorated path matcher does not match")
	}

	public void function Root() {
		var pathMatcher = new RootPathMatcher("index")

		var path1 = []
		var path2 = ["index"]
		var path3 = ["index", "dir"]
		assertEquals(1, pathMatcher.match(path1, "root path matcher should match empty path"))
		assertEquals(1, pathMatcher.match(path2, "root path matcher should match path with only index"))
		assertEquals(0, pathMatcher.match(path3, "root path matcher should not match paths with multiple segments"))
	}

}