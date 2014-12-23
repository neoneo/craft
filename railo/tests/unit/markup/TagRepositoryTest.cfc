import craft.markup.TagRepository;

component extends="tests.MocktorySpec" {

	function run() {

		describe("TagRepository", function () {

			beforeEach(function () {
				elementFactory = mock({
					$interface: "ElementFactory"
				})
				tagRepository = new TagRepository(elementFactory)

				mapping = "/tests/unit/markup/stubs"
				dotMapping = mapping.listChangeDelims(".", "/")
			})

			describe(".register", function () {

				var sameItems = function (expected, actual) {
					return arguments.expected.containsAll(arguments.actual) && arguments.actual.containsAll(arguments.expected);
				}


				it("should register nothing if craft.ini is not found", function () {
					tagRepository.register(mapping & "/nosettings")
					expect(tagRepository.tagNames).toBeEmpty()
				})

				it("should throw ConfigurationException if no craft section is defined in craft.ini", function () {
					expect(function () {
						tagRepository.register(mapping & "/nocraftsection")
					}).toThrow("ConfigurationException")
				})

				it("should throw ConfigurationException if no namespace is defined in craft.ini", function () {
					expect(function () {
						tagRepository.register(mapping & "/nonamespace")
					}).toThrow("ConfigurationException")
				})

				it("should register only elements, and only those that are not abstract", function () {
					tagRepository.register(mapping & "/recursive/dir2/sub")

					var tags = tagRepository.tagNames

					expect(tags).toHaveKey("http://neoneo.nl/craft/dir2")
					tagNames = tags["http://neoneo.nl/craft/dir2"]

					expect(tagNames.find("noelement")).toBe(0)
					expect(tagNames.find("abstractelement")).toBe(0)
					expect(sameItems(tagNames, ["extendsextendssome", "extendssome", "some"])).toBeTrue()
				})

				it("should register elements in subdirectories", function () {
					tagRepository.register(mapping & "/recursive/dir1")

					var tags = tagRepository.tagNames

					expect(tags).toHaveKey("http://neoneo.nl/craft/dir1")
					tagNames = tags["http://neoneo.nl/craft/dir1"]

					// There are 2 directories, with 1 element each.
					expect(tagNames).toHaveLength(2)
					// SomeElement has no tag annotation, so the fully qualified name should be returned.
					expect(sameItems(tagNames, ["dir1sub", dotMapping & ".recursive.dir1.SomeElement"])).toBeTrue()
				})

				it("should register multiple namespaces", function () {
					tagRepository.register(mapping & "/recursive")

					var tags = tagRepository.tagNames
					expect(tags).toHaveKey("http://neoneo.nl/craft/dir1")
					expect(tags).toHaveKey("http://neoneo.nl/craft/dir2")
				})

				it("should follow the directories directive", function () {
					tagRepository.register(mapping & "/directory")

					var tags = tagRepository.tagNames
					expect(tags).toHaveKey("http://neoneo.nl/craft/directory")
					tagNames = tags["http://neoneo.nl/craft/directory"]

					// There are 3 directories that should be inspected, with 1 element each.
					expect(sameItems(tagNames, ["yes", "yessub", "subyes"])).toBeTrue()
				})

				it("should throw AlreadyBoundException if a tag by the given name is already registered", function () {
					expect(function () {
						tagRepository.register(mapping & "/multiple/tagnames")
					}).toThrow("AlreadyBoundException")
				})

				it("should throw AlreadyBoundException if a namespace by the given name is already registered", function () {
					expect(function () {
						tagRepository.register(mapping & "/multiple/namespaces")
					}).toThrow("AlreadyBoundException")
				})

			})

			describe(".elementFactory", function () {

				it("should return the default factory if there is not factory directive", function () {
					tagRepository.register(mapping & "/factory/nodirective")

					$assert.isSameInstance(elementFactory, tagRepository.elementFactory("http://neoneo.nl/craft/factory/nodirective"))
				})

				it("should return the factory defined by the factory directive", function () {
					tagRepository.register(mapping & "/factory/directive")

					var elementFactory = tagRepository.elementFactory("http://neoneo.nl/craft/factory/directive")
					expect(elementFactory).toBeInstanceOf(dotMapping & ".factory.directive.ElementFactoryStub")
				})

				it("should throw NotBoundException if no namespace by the given name is registered", function () {
					expect(function () {
						tagRepository.elementFactory("nonexisting")
					}).toThrow("NotBoundException")
				})

			})

			describe(".setElementFactory", function () {

				it("should set the factory for the given namespace", function () {
					tagRepository.register(mapping & "/factory/nodirective")
					// Set some element factory for the namespace just registered.
					var elementFactory = mock({$interface: "ElementFactory"})
					tagRepository.setElementFactory("http://neoneo.nl/craft/factory/nodirective", elementFactory)

					$assert.isSameInstance(elementFactory, tagRepository.elementFactory("http://neoneo.nl/craft/factory/nodirective"))
				})

				it("should throw NotBoundException if no namespace by the given name is registered", function () {
					var elementFactory = mock({$interface: "ElementFactory"})
					expect(function () {
						tagRepository.setElementFactory("http://neoneo.nl/craft/", elementFactory)
					}).toThrow("NotBoundException")

					tagRepository.register(mapping & "/factory/nodirective")
					expect(function () {
						tagRepository.setElementFactory("http://neoneo.nl/craft/nonexisting", elementFactory)
					}).toThrow("NotBoundException")
				})

			})

			describe(".deregisterNamespace", function () {

				it("should remove the namespace by the given name", function () {
					tagRepository.register(mapping & "/recursive")

					tagRepository.deregisterNamespace("http://neoneo.nl/craft/dir2")

					// Test.
					var tags = tagRepository.tagNames
					expect(tags).toHaveKey("http://neoneo.nl/craft/dir1")
					expect(tags).notToHaveKey("http://neoneo.nl/craft/dir2")
				})

			})

			describe(".deregister", function () {

				it("should remove the namespace defined in craft.ini", function () {
					// First register some namespaces.
					tagRepository.register(mapping & "/recursive")

					// Deregister one of the mappings.
					tagRepository.deregister(mapping & "/recursive/dir2")

					// Test.
					var tags = tagRepository.tagNames
					expect(tags).toHaveKey("http://neoneo.nl/craft/dir1")
					expect(tags).notToHaveKey("http://neoneo.nl/craft/dir2")
				})

				it("should throw NotBoundException if no craft section is defined in craft.ini", function () {
					expect(function () {
						tagRepository.deregister(mapping & "/nocraftsection")
					}).toThrow("NotBoundException")
				})

				it("should throw NotBoundException if no namespace is defined in craft.ini", function () {
					expect(function () {
						tagRepository.deregister(mapping & "/nonamespace")
					}).toThrow("NotBoundException")
				})

			})

			describe(".get", function () {

				it("should throw NotBoundException if no namespace by the given name is registered", function () {
					tagRepository.register(mapping & "/create")

					expect(function () {
						tagRepository.get("http://doesnotexist", "tagelement")
					}).toThrow("NotBoundException")
				})

				it("should throw NotBoundException if no tag by the given name is registered", function () {
					tagRepository.register(mapping & "/create")

					expect(function () {
						tagRepository.get("http://neoneo.nl/craft", "doesnotexist")
					}).toThrow("NotBoundException")
				})

				it("should return the corresponding tag metadata if requested by tag name", function () {
					tagRepository.register(mapping & "/create")

					var metadata = tagRepository.get("http://neoneo.nl/craft", "tagelement")

					expect(metadata.class).toBe(dotMapping & ".create.TagElement")
				})

				it("should return the corresponding tag metadata if requested by class name", function () {
					tagRepository.register(mapping & "/create")

					var metadata = tagRepository.get("http://neoneo.nl/craft", dotMapping & ".create.NoTagElement")

					expect(metadata.class).toBe(dotMapping & ".create.NoTagElement")
				})

			})

		})

	}

}