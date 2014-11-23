import craft.request.*;

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

				it("should return the parent or null", function () {
					expect(segment.hasParent).toBeFalse()
					expect(segment.parent).toBeNull()

					var parent = segment.parent = new PathSegment()
					expect(segment.hasParent).toBeTrue()
					$assert.isSameInstance(parent, segment.parent)
				})

			})

			describe("child relationships", function () {

				beforeEach(function () {
					collection = mock({
						$class: "Collection",
						isEmpty: true,
						toArray: [],
						add: {
							$results: [true, false]
						},
						remove: {
							$results: [true, false]
						}
					})
					segment = mock("PathSegment")
					segment.$("createCollection", collection)
					segment.init()
				})

				describe(".hasChildren", function () {

					it("should call collection.isEmpty", function () {
						expect(segment.hasChildren).toBeFalse() // The negation of isEmpty.
						expect(collection.$count("isEmpty")).toBe(1)
					})

				})

				describe(".addChild", function () {

					it("should call collection.add and set the parent on the child when successful", function () {
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

					it("before existing child should call collection.add", function () {
						var child = new PathSegment()
						var beforeChild = new PathSegment()

						var success = segment.addChild(child, beforeChild)

						expect(success).toBeTrue()
						expect(collection.$count("add")).toBe(1)
						var callLog = collection.$callLog()
						$assert.isSameInstance(child, callLog.add[1][1])
						$assert.isSameInstance(beforeChild, callLog.add[1][2])
					})

				})

				describe(".removeChild", function () {

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