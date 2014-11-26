import craft.request.PathSegment;
import craft.request.RoutesParser;

component extends="tests.MocktorySpec" {

	function verifyCommand(pathSegment, method, identifier) {
		verify(commandFactory, {
			create: {
				$args: [identifier],
				$times: 1
			}
		})
		expect(arguments.pathSegment.command(method).getIdentifier()).toBe(arguments.identifier)
	}

	function run() {

		describe("RoutesParser", function () {

			describe(".parse", function () {

				beforeEach(function () {
					root = new PathSegment()

					pathSegmentFactory = mock({
						$class: "PathSegmentFactory",
						create: function (pattern, parameterName) {
							return new PathSegment(pattern, parameterName);
						}
					})

					commandFactory = mock({
						$interface: "CommandFactory",
						create: function (identifier) {
							return mock({
								$interface: "Command",
								identifier: arguments.identifier
							})
						}
					})

					parser = new RoutesParser(root, pathSegmentFactory, commandFactory)
				})

				it("should throw NoSuchElementException if there are not enough words", function () {
					var route = "GET /index"
					expect(function () {
						parser.parse(route)
					}).toThrow("NoSuchElementException")
				})

				it("should parse '/'", function () {
					var route = "GET / rootcommand"

					var pathSegment = parser.parse(route)

					$assert.isSameInstance(root, pathSegment)

					verifyCommand(root, "GET", "rootcommand")

					verify(pathSegmentFactory, {
						create: {
							$times: 0
						}
					})
				})

				it("should parse a one level path", function () {
					var route = "GET /level1 level1command"

					var pathSegment = parser.parse(route)

					expect(pathSegment.pattern).toBe("level1")

					$assert.isSameInstance(root, pathSegment.parent)

					verifyCommand(pathSegment, "GET", "level1command")

					verify(pathSegmentFactory, {
						create: {
							$times: 0
						}
					})
				})

				it("should parse a two level path", function () {
					var route = "GET /level1/level2 level2command"

					var pathSegment = parser.parse(route)

					expect(pathSegment.pattern).toBe("level2")
					verifyCommand(pathSegment, "GET", "level2command")

					// Intermediate path segments should have been created.
					var parent = pathSegment.parent
					expect(parent.pattern).toBe("level1")

					$assert.isSameInstance(root, parent.parent)

					verify(pathSegmentFactory, {
						create: {
							$times: 2
						}
					})
				})

				it("should parse a path that does not start with a slash", function () {
					var route = "GET index indexcommand"
					var pathSegment = parser.parse(route)

					// The route should be equal to /index.
					$assert.isSameInstance(root, pathSegment.parent)
					verifyCommand(pathSegment, "GET", "indexcommand")
				})

				it("should add a path segment to an existing parent", function () {
					var level1 = new PathSegment("level1")
					root.addChild(level1)

					var route = "GET /level1/level2 level2command"

					var pathSegment = parser.parse(route)

					expect(pathSegment.pattern).toBe("level2")

					// Intermediate path segments should have been created.
					var parent = pathSegment.parent
					expect(parent.pattern).toBe("level1")

					$assert.isSameInstance(root, parent.parent)

					verifyCommand(pathSegment, "GET", "level2command")

					verify(pathSegmentFactory, {
						create: {
							$times: 2
						}
					})

				})

				it("should parse two routes with different http methods and return the same path segment", function () {
					var route1 = "GET /level1 getcommand"
					var route2 = "POST /level1 postcommand"

					var pathSegment1 = parser.parse(route1)
					var pathSegment2 = parser.parse(route2)

					// We should have the exact same instance twice.
					$assert.isSameInstance(pathSegment1, pathSegment2)

					verifyCommand(pathSegment1, "GET", "getcommand")
					verifyCommand(pathSegment1, "POST", "postcommand")

					verify(pathSegmentFactory, {
						create: {
							$times: 1
						}
					})
				})

				it("should set the parameter if specified using @", function () {
					var route1 = "GET /index@par1 indexcommand"
					var pathSegment1 = parser.parse(route1)

					expect(pathSegment1.pattern).toBe("index")
					expect(pathSegment1.parameterName).toBe("par1")


					var route2 = "GET /index/route@par2 routecommand"
					var pathSegment2 = parser.parse(route2)

					$assert.isSameInstance(pathSegment1, pathSegment2.parent)
					expect(pathSegment2.pattern).toBe("route")
					expect(pathSegment2.parameterName).toBe("par2")

					verifyCommand(pathSegment1, "GET", "indexcommand")
					verifyCommand(pathSegment2, "GET", "routecommand")
				})

				it("should set the correct parameter if the route contains an escaped @", function () {
					var route1 = "GET /index\@escaped@par indexcommand"
					var pathSegment = parser.parse(route1)

					expect(pathSegment.pattern).toBe("index@escaped")
					expect(pathSegment.parameterName).toBe("par")

					verifyCommand(pathSegment, "GET", "indexcommand")

					var route2 = "GET /wrong@escaped@par index"
					expect(function () {
						parser.parse(route2)
					}).toThrow("IllegalArgumentException")
				})

				it("should ignore multiple whitespace characters", function () {
					var route = "#Chr(9)#GET#Chr(9)#/       rootcommand   "
					var pathSegment = parser.parse(route)

					$assert.isSameInstance(root, pathSegment)
					verifyCommand(pathSegment, "GET", "rootcommand")
				})

				describe("for relative routes", function () {

					it("should throw NoSuchElementException if an invalid indent is encountered", function () {
						var route1 = "GET > /route1 route1"
						expect(function () {
							parser.parse(route1)
						}).toThrow("NoSuchElementException")

						// For the next test, parse a proper route first.
						var route = "GET / root"
						var pathSegment = parser.parse(route)
						// Now indent too far:
						var route2 = "GET >> /route2 route2"
						expect(function () {
							parser.parse(route2)
						}).toThrow("NoSuchElementException")
					})

					it("should interpret a dot as the current route", function () {
						var dotRoute = "GET . getcommand"
						// Parsing this right away should throw an exception.
						expect(function () {
							parser.parse(dotRoute)
						}).toThrow("NoSuchElementException")

						// First parsing a route and then the dot route should work.
						var route = "POST /route postcommand" // Use a differen method, so we get two commands.
						var pathSegment = parser.parse(route)

						var dotPathSegment = parser.parse(dotRoute)

						$assert.isSameInstance(pathSegment, dotPathSegment)
						verifyCommand(pathSegment, "GET", "getcommand")
						verifyCommand(pathSegment, "POST", "postcommand")

						// If another dot route follows, this shouldn't be a problem.
						var dotRoute2 = "PUT . putcommand"
						var dotPathSegment2 = parser.parse(dotRoute2)
						$assert.isSameInstance(pathSegment, dotPathSegment2)
						verifyCommand(pathSegment, "PUT", "putcommand")
					})

					it("should parse a single indent", function () {
						var route = "GET / root"
						// Parse this, so that the next call can use the indent.
						var pathSegment = parser.parse(route)

						var indent1 = "GET > /indent1 indent1command"
						var indent2 = "GET > /indent2 indent2command"

						var pathSegment1 = parser.parse(indent1)
						var pathSegment2 = parser.parse(indent2)

						// Since it's relative to the root, the presence of the indent should not matter.
						$assert.isSameInstance(pathSegment, pathSegment1.parent)
						verifyCommand(pathSegment1, "GET", "indent1command")
						verifyCommand(pathSegment2, "GET", "indent2command")
					})

					it("should parse multiple indents and dedents", function () {
						// Test this relative to some other path than the root.
						var route = "GET /route routecommand"
						var pathSegment = parser.parse(route)

						var indent1 = "GET > /indent1 indent1command" // /index/indent1
						var pathSegment1 = parser.parse(indent1)

						var indent2 = "GET >> /indent2 indent2command" // /index/indent1/indent2
						var pathSegment2 = parser.parse(indent2)

						var indent3 = "GET >>> /indent3 indent3command" // /index/indent1/indent2/indent3
						var pathSegment3 = parser.parse(indent3)

						$assert.isSameInstance(pathSegment, pathSegment1.parent)
						verifyCommand(pathSegment1, "GET", "indent1command")

						$assert.isSameInstance(pathSegment1, pathSegment2.parent)
						verifyCommand(pathSegment2, "GET", "indent2command")

						$assert.isSameInstance(pathSegment2, pathSegment3.parent)
						verifyCommand(pathSegment3, "GET", "indent3command")

						// Dedent:
						var dedent4 = "GET > /dedent4 dedent4command" // /index/dedent4
						var pathSegment4 = parser.parse(dedent4)

						$assert.isSameInstance(pathSegment, pathSegment4.parent)
						verifyCommand(pathSegment4, "GET", "dedent4command")

						// Now indent again (should be relative to the previous route):
						var indent5 = "GET >> /indent5 indent5command" // /index/dedent4/indent5
						var pathSegment5 = parser.parse(indent5)

						$assert.isSameInstance(pathSegment4, pathSegment5.parent)
						verifyCommand(pathSegment5, "GET", "indent5command")

						// Same path:
						var dot6 = "POST . dot6command" // /index/dedent4/indent5
						var pathSegment6 = parser.parse(dot6)

						$assert.isSameInstance(pathSegment5, pathSegment6)
						verifyCommand(pathSegment6, "POST", "dot6command")
					})

				})

			})

			describe(".remove", function () {

				it("should throw NoSuchElementException if the route does not exist", function () {
					// Test immediately. The root has no children, so any route suffices.
					expect(function () {
						parser.remove("GET /child")
					}).toThrow("NoSuchElementException")
				})

				it("should remove the route if it exists", function () {
					// Add some routes to the root.
					mock({
						$object: root,
						children: [
							{
								$class: "PathSegment",
								pattern: "child1",
								removeCommand: null,
								children: []
							},
							{
								$class: "PathSegment",
								pattern: "child2",
								removeCommand: null,
								children: [
									{$class: "PathSegment", pattern: "grandchild1", removeCommand: null},
									{$class: "PathSegment", pattern: "grandchild2", removeCommand: null}
								]
							}
						]
					})

					var child1 = root.children[1]
					var child2 = root.children[2]
					var grandchild1 = child2.children[1]
					var grandchild2 = child2.children[2]

					// No identifier should be required so we leave it off.
					parser.remove("GET /child2/grandchild2")

					verify(grandchild2, {
						removeCommand: {
							$args: ["GET"],
							$times: 1
						}
					})

					parser.remove("POST /child1")

					verify(child1, {
						removeCommand: {
							$args: ["POST"],
							$times: 1
						}
					})

					parser.remove("PUT /child2")

					verify(child2, {
						removeCommand: {
							$args: ["PUT"],
							$times: 1
						}
					})

					parser.remove("DELETE /child2/grandchild1")

					verify(grandchild1, {
						removeCommand: {
							$args: ["DELETE"],
							$times: 1
						}
					})

				})

			})

		})

	}

}