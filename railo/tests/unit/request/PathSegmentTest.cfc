import craft.request.DynamicPathSegment;
import craft.request.EntirePathSegment;
import craft.request.PathSegment;
import craft.request.RootPathSegment;
import craft.request.StaticPathSegment;

component extends="tests.MocktorySpec" {

	function run() {

		describe("PathSegment", function () {

			describe(".pattern and .parameterName", function () {

				it("should return the constructor values", function () {
					var segment = new PathSegment("pattern", "parameter")
					expect(segment.pattern).toBe("pattern")
					expect(segment.parameterName).toBe("parameter")
				})

			})

			describe(".command", function () {

				beforeEach(function () {
					segment = new PathSegment()
				})

				it("should return corresponding command", function () {
					var command1 = createStub(implements = "craft.request.Command")
					var command2 = createStub(implements = "craft.request.Command")

					expect(segment.hasCommand()).toBeFalse()

					segment.setCommand("GET", command1)
					segment.setCommand("POST", command2)

					expect(segment.hasCommand()).toBeTrue()
					expect(segment.hasCommand("GET")).toBeTrue()
					expect(segment.hasCommand("DELETE")).toBeFalse()

					$assert.isSameInstance(command1, segment.command("GET"))
					$assert.isSameInstance(command2, segment.command("POST"))

					segment.removeCommand("GET")
					expect(segment.hasCommand("GET")).toBeFalse()

					segment.removeCommand("POST")
					expect(segment.hasCommand("POST")).toBeFalse()
					expect(segment.hasCommand()).toBeFalse()
				})

				it("should throw NoSuchElementException if the command does not exist", function () {
					expect(function () {
						segment.command("POST")
					}).toThrow("NoSuchElementException")

					// Test again, now with some other command present.
					segment.setCommand("GET", createStub(implements = "craft.request.Command"))

					expect(function () {
						segment.command("POST")
					}).toThrow("NoSuchElementException")
				})

			})

			describe(".parent", function () {

				beforeEach(function () {
					segment = new PathSegment()
				})

				it("should return the parent or null", function () {
					expect(segment.hasParent).toBeFalse()
					expect(segment.parent).toBeNull()

					var parent = segment.parent = new PathSegment()
					expect(segment.hasParent).toBeTrue()
					$assert.isSameInstance(parent, segment.parent)
				})

			})

			describe("child relationship", function () {

				beforeEach(function () {
					collection = mock({
						$class: "Collection",
						isEmpty: true,
						toArray: []
					})
					segment = mock({
						$class: "PathSegment",
						createCollection: collection
					})
					segment.init()
				})

				describe(".children", function () {

					it("should return all children as an array", function () {
						expect(segment.children).toBeArray()
						verify(collection, {
							toArray: {
								$times: 1
							}
						})
					})

				})

				describe(".hasChildren", function () {

					it("should return whether the path segment has any children", function () {
						expect(segment.hasChildren).toBeFalse() // The negation of isEmpty.
						expect(collection.$count("isEmpty")).toBe(1)
					})

				})

				describe(".addChild", function () {

					beforeEach(function () {
						mock({
							$object: collection,
							add: {
								$results: [true, false]
							}
						})
					})

					it("should add the child to the end and set the parent on the child when successful", function () {
						var child1 = new PathSegment()

						var success = segment.addChild(child1)

						expect(success).toBeTrue()
						verify(collection, {
							add: {
								$args: [child1, null],
								$times: 1
							}
						})
						$assert.isSameInstance(segment, child1.parent)

						// Add another child. The collection will now return false.
						var child2 = new PathSegment()

						var success = segment.addChild(child2)

						expect(success).toBeFalse()
						verify(collection, {
							add: {
								$args: [child2, null],
								$times: 1
							}
						})
						expect(child2.parent).toBeNull()
					})

					it("should add the child before the existing child and set the parent on the child when successful", function () {
						var child = new PathSegment()
						var beforeChild = new PathSegment()

						var success = segment.addChild(child, beforeChild)

						expect(success).toBeTrue()
						verify(collection, {
							add: {
								$args: [child, beforeChild],
								$times: 1
							}
						})
						$assert.isSameInstance(segment, child.parent)
					})

				})

				describe(".removeChild", function () {

					beforeEach(function () {
						mock({
							$object: collection,
							remove: {
								$results: [true, false]
							}
						})
					})

					it("should remove if the path segment is a child, and set its parent to null when successful", function () {
						var child1 = new PathSegment()
						child1.parent = segment

						var success = segment.removeChild(child1)

						expect(success).toBeTrue()
						verify(collection, {
							remove: {
								$args: [child1],
								$times: 1
							}
						})
						expect(child1.parent).toBeNull()

						// Remove another child. This will now return false.
						var child2 = new PathSegment()
						child2.parent = child1

						var success = segment.removeChild(child2)

						expect(success).toBeFalse()
						verify(collection, {
							remove: {
								$args: [child2],
								$times: 1
							}
						})
						$assert.isSameInstance(child1, child2.parent)
					})

				})

				describe(".moveChild", function () {

					beforeEach(function () {
						mock({
							$object: collection,
							move: true
						})
					})

					it("should move the child to the end if no before child is provided", function () {
						var child = new PathSegment()

						var success = segment.moveChild(child)

						expect(success).toBeTrue()
						verify(collection, {
							move: {
								$args: [child, null],
								$times: 1
							}
						})
					})

					it("should move the child before the existing child", function () {
						var child = new PathSegment()
						var beforeChild = new PathSegment()

						var success = segment.moveChild(child, beforeChild)

						expect(success).toBeTrue()
						verify(collection, {
							move: {
								$args: [child, beforeChild],
								$times: 1
							}
						})
					})

				})

			})

			describe(".walk", function () {

				beforeEach(function () {
					// Create a path structure that contains segments using all types of path matchers
					// FIXME: We're using real objects where mocks should be used.
					root = new RootPathSegment()
					index = new StaticPathSegment("index")
					test1 = new StaticPathSegment("test1", "first")
					test2 = new StaticPathSegment("test2", "second")
					entire = new EntirePathSegment("entire")

					mock({
						$object: root,
						children: [
							{
								$object: index
							},
							{
								$object: test1,
								children: [
									{
										$object: test2
									}
								]
							},
							{
								$object: entire
							}
						]
					})
				})

				it("should return the root path segment if the path is empty", function () {
					var result = root.walk([])
					$assert.isSameInstance(root, result.target)
				})

				it("should return the matching path segment for a path of one segment", function () {
					var result = root.walk(["index"])
					$assert.isSameInstance(index, result.target)
				})

				it("should set the matching path segment and set the request parameter to the matched segment", function () {
					var result = root.walk(["test1"])
					$assert.isSameInstance(test1, result.target)
					var parameters = result.parameters
					expect(parameters).toHaveKey("first")
					expect(parameters.first).toBe("test1")
				})

				it("should set the matching child path segment and set request parameters for the matching segments", function () {
					var result = root.walk(["test1", "test2"]) // This corresponds to path '/test1/test2'
					$assert.isSameInstance(test2, result.target)
					var parameters = result.parameters
					expect(parameters).toHaveKey("first")
					expect(parameters.first).toBe("test1")
					expect(parameters).toHaveKey("second")
					expect(parameters.second).toBe("test2")
				})

				it("should continue matching when the path was matched partially", function () {
					// the test3 segment is not mapped, so the search should move on to the entire path matcher
					var result = root.walk(["test1", "test2", "test3"])
					$assert.isSameInstance(entire, result.target)
					var parameters = result.parameters
					expect(parameters).toHaveKey("entire")
					expect(parameters.entire).toBe("test1/test2/test3")
				})

			})

		})

		describe("Matching paths", function () {

			beforeEach(function () {
				path1 = ["dir1", "dir2", "dir3"]
				path2 = ["dir2"]
				path3 = ["dirA"]
			})

			describe("EntirePathSegment", function () {

				it("should match the entire path", function () {
					var segment = new EntirePathSegment()
					expect(segment.match(path1)).toBe(path1.len())
					expect(segment.match(path2)).toBe(path2.len())
					expect(segment.match(path3)).toBe(path3.len())
				})

			})

			describe("StaticPathSegment", function () {

				it("should match the first segment exactly", function () {
					var segment = new StaticPathSegment("dir1")

					expect(segment.match(path1)).toBe(1)
					expect(segment.match(path2)).toBe(0)
					expect(segment.match(path3)).toBe(0)
				})

			})

			describe("DynamicPathSegment", function () {

				it("should match the pattern against the complete first segment", function () {
					var segment = new DynamicPathSegment("dir[0-9]")

					expect(segment.match(path1)).toBe(1)
					expect(segment.match(path2)).toBe(1)
					expect(segment.match(path3)).toBe(0)

					var path = ["dir10"]
					expect(segment.match(path)).toBe(0, "the pattern should match against the complete segment")
				})
			})

		})

	}

}