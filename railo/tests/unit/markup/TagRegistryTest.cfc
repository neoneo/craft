import craft.markup.TagRegistry;

component extends="tests.MocktorySpec" {

	function run() {

		describe("TagRegistry", function () {

			beforeEach(function () {
				objectProvider = mock({
					$class: "ObjectProvider"
				})
				tagRegistry = new TagRegistry(objectProvider)

				mapping = "/tests/unit/markup/tagregistry"
				dotMapping = mapping.listChangeDelims(".", "/")
			})

			describe(".register", function () {

				beforeEach(function () {
					mock({
						$object: objectProvider,
						spawn: objectProvider, // Just return the same instance, so we can track function calls.
						registerAll: null
					})
				})

				it("should register nothing if craft.ini is not found", function () {
					tagRegistry.register(mapping & "/nosettings")
					expect(tagRegistry.namespaces).toBeEmpty()
				})

				it("should throw ConfigurationException if no craft section is defined in craft.ini", function () {
					expect(function () {
						tagRegistry.register(mapping & "/nocraftsection")
					}).toThrow("ConfigurationException")
				})

				it("should throw ConfigurationException if no namespace is defined in craft.ini", function () {
					expect(function () {
						tagRegistry.register(mapping & "/nonamespace")
					}).toThrow("ConfigurationException")
				})

				it("should spawn a new object provider and register the mapping there", function () {
					var registerMapping = mapping & "/recursive/dir2/sub"
					tagRegistry.register(registerMapping)

					var namespaces = tagRegistry.namespaces
					expect(namespaces).toBe(["http://neoneo.nl/craft/dir2"])
					verify(objectProvider, {
						spawn: {
							$args: [],
							$times: 1
						},
						registerAll: {
							$args: [registerMapping],
							$times: 1
						}
					})
				})

				it("should register multiple namespaces", function () {
					tagRegistry.register(mapping & "/recursive")

					var namespaces = tagRegistry.namespaces
					expect(namespaces).toBe(["http://neoneo.nl/craft/dir1", "http://neoneo.nl/craft/dir2"])
				})

				it("should only register mappings defined in the directories directive", function () {
					var registerMapping = mapping & "/directories"
					tagRegistry.register(registerMapping)

					var namespaces = tagRegistry.namespaces
					expect(namespaces).toBe(["http://neoneo.nl/craft/directory"])

					verify(objectProvider, {
						spawn: {
							$args: [],
							$times: 1
						},
						registerAll: [
							{
								$args: [registerMapping & "/yes"],
								$times: 1
							},
							{
								$args: [registerMapping & "/sub/yes"],
								$times: 1
							}
						]
					})
				})

				it("should throw AlreadyBoundException if a namespace by the given name is already registered", function () {
					expect(function () {
						tagRegistry.register(mapping & "/existingnamespace")
					}).toThrow("AlreadyBoundException")
				})

			})

			xdescribe(".elementFactory", function () {

				it("should return the default factory if there is not factory directive", function () {
					tagRegistry.register(mapping & "/factory/nodirective")

					$assert.isSameInstance(elementFactory, tagRegistry.elementFactory("http://neoneo.nl/craft/factory/nodirective"))
				})

				it("should return the factory defined by the factory directive", function () {
					tagRegistry.register(mapping & "/factory/directive")

					var elementFactory = tagRegistry.elementFactory("http://neoneo.nl/craft/factory/directive")
					expect(elementFactory).toBeInstanceOf(dotMapping & ".factory.directive.ElementFactoryStub")
				})

				it("should throw NotBoundException if no namespace by the given name is registered", function () {
					expect(function () {
						tagRegistry.elementFactory("nonexisting")
					}).toThrow("NotBoundException")
				})

			})

			xdescribe(".setElementFactory", function () {

				it("should set the factory for the given namespace", function () {
					tagRegistry.register(mapping & "/factory/nodirective")
					// Set some element factory for the namespace just registered.
					var elementFactory = mock({$interface: "ElementFactory"})
					tagRegistry.setElementFactory("http://neoneo.nl/craft/factory/nodirective", elementFactory)

					$assert.isSameInstance(elementFactory, tagRegistry.elementFactory("http://neoneo.nl/craft/factory/nodirective"))
				})

				it("should throw NotBoundException if no namespace by the given name is registered", function () {
					var elementFactory = mock({$interface: "ElementFactory"})
					expect(function () {
						tagRegistry.setElementFactory("http://neoneo.nl/craft/", elementFactory)
					}).toThrow("NotBoundException")

					tagRegistry.register(mapping & "/factory/nodirective")
					expect(function () {
						tagRegistry.setElementFactory("http://neoneo.nl/craft/nonexisting", elementFactory)
					}).toThrow("NotBoundException")
				})

			})

			describe(".deregisterNamespace", function () {

				it("should remove the namespace by the given name", function () {
					tagRegistry.register(mapping & "/recursive")

					var namespaces = tagRegistry.namespaces
					expect(namespaces).toBe(["http://neoneo.nl/craft/dir1", "http://neoneo.nl/craft/dir2"])

					tagRegistry.deregisterNamespace("http://neoneo.nl/craft/dir2")

					var namespaces = tagRegistry.namespaces
					expect(namespaces).toBe(["http://neoneo.nl/craft/dir1"])
				})

			})

			describe(".deregister", function () {

				it("should remove the namespace defined in craft.ini", function () {
					// First register some namespaces.
					tagRegistry.register(mapping & "/recursive")

					var namespaces = tagRegistry.namespaces
					expect(namespaces).toBe(["http://neoneo.nl/craft/dir1", "http://neoneo.nl/craft/dir2"])

					// Deregister one of the mappings.
					tagRegistry.deregister(mapping & "/recursive/dir2")

					var namespaces = tagRegistry.namespaces
					expect(namespaces).toBe(["http://neoneo.nl/craft/dir1"])
				})

				it("should throw NotBoundException if no craft section is defined in craft.ini", function () {
					expect(function () {
						tagRegistry.deregister(mapping & "/nocraftsection")
					}).toThrow("NotBoundException")
				})

				it("should throw NotBoundException if no namespace is defined in craft.ini", function () {
					expect(function () {
						tagRegistry.deregister(mapping & "/nonamespace")
					}).toThrow("NotBoundException")
				})

			})

			describe(".get", function () {

				it("should throw NotBoundException if no namespace by the given name is registered", function () {
					tagRegistry.register(mapping & "/recursive/dir1")

					expect(function () {
						tagRegistry.get("http://doesnotexist")
					}).toThrow("NotBoundException")
				})

				it("should return the corresponding object provider", function () {
					var descriptor = {
						$class: "ObjectProvider",
						registerAll: null
					}
					var dir1 = mock(descriptor)
					var dir2 = mock(descriptor)
					// Just to be sure, verify that we have different instances.
					$assert.isNotSameInstance(dir1, dir2)
					mock({
						$object: objectProvider,
						spawn: {
							$results: [dir1, dir2] // Return dir1 and dir2 interchangeably.
						}
					})

					tagRegistry.register(mapping & "/recursive")

					var result1 = tagRegistry.get("http://neoneo.nl/craft/dir1")
					$assert.isSameInstance(dir1, result1)
					var result2 = tagRegistry.get("http://neoneo.nl/craft/dir2")
					$assert.isSameInstance(dir2, result2)
				})

			})

		})

	}

}