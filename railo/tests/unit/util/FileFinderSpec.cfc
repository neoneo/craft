import craft.util.*;

component extends="testbox.system.BaseSpec" {

	function beforeAll() {
		mapping = "/tests/unit/util/files"
	}

	function run() {

		describe("FileFinder", function () {

			beforeEach(function () {
				fileFinder = new FileFinder("txt")
			})

			describe(".get", function () {

				it("should throw FileNotFoundException when no mapping is available", function () {
					expect(function () {
						fileFinder.get("file")
					}).toThrow("FileNotFoundException")
				})

				it("should return the file name when the file exists in one of the mappings", function () {
					fileFinder.addMapping(mapping & "/dir1")
					var file = fileFinder.get("file1") // OK
					expect(file).toInclude("/dir1/file1.txt", "file1.txt should be found in dir1")
				})

				it("should throw FileNotFoundException when the file does not exist in one of the mappings", function () {
					expect(function () {
						fileFinder.addMapping(mapping & "/dir1")
						fileFinder.get("file3")
					}).toThrow("FileNotFoundException")
				})

				it("should search mappings in order", function () {
					fileFinder.addMapping(mapping & "/dir1")
					fileFinder.addMapping(mapping & "/dir2")
					fileFinder.addMapping(mapping & "/dir3")

					var file = fileFinder.get("file1") // OK: from dir1
					expect(file).toInclude("/dir1/file1.txt", "file1.txt should be found in dir1")

					var file = fileFinder.get("file2") // OK: from dir1 (also exists in dir2)
					expect(file).toInclude("/dir1/file2.txt", "file2.txt should be found in dir1")

					var file = fileFinder.get("file3") // OK: from dir2 (also exists in dir3)
					expect(file).toInclude("/dir2/file3.txt", "file3.txt should be found in dir2")

					var file = fileFinder.get("file4") // OK: from dir3
					expect(file).toInclude("/dir3/file4.txt", "file4.txt should be found in dir3")
				})

				it("should not search removed mappings", function () {
					fileFinder.addMapping(mapping & "/dir1")
					fileFinder.addMapping(mapping & "/dir2")
					fileFinder.get("file1") // from dir1
					fileFinder.get("file2") // from dir1

					fileFinder.removeMapping(mapping & "/dir1")

					var file = fileFinder.get("file2") // now from dir2
					expect(file).toInclude("/dir2/file2.txt", "file2.txt should be found in dir2")

					expect(function () {
						fileFinder.get("file1")
					}).toThrow("FileNotFoundException")

					fileFinder.clear()
					expect(function () {
						fileFinder.get("file2")
					}).toThrow("FileNotFoundException")
				})

			})

		})

	}

}