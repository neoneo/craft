import craft.core.util.DirectoryWatcher;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {

		variables.directory = Replace(GetTempDirectory(), "\", "/", "all") & CreateGUID() & "/"
		DirectoryCreate(variables.directory)
		DirectoryCreate(variables.directory & "sub1") // create a subdirectory for recursive tests
		// create some files for the tests
		FileWrite(variables.directory & "nodir", "nodir")
		FileWrite(variables.directory & "delete.txt", "delete")
		FileWrite(variables.directory & "modify.txt", "modify")
		FileWrite(variables.directory & "rename.txt", "rename")

		variables.wait = 10100 // the watcher checks once every 10 seconds
	}

	public void function tearDown() {
		if (StructKeyExists(variables, "watcher")) {
			variables.watcher.close()
		}
		DirectoryDelete(variables.directory, true)
	}

	public void function WatchingNonExistingDirectory_Should_ThrowInvalidArgumentException() {
		try {
			variables.watcher = createWatcher(variables.directory & "0", false)
			variables.watcher.close()
			fail("trying to watch a directory that does not exist should throw an exception")
		} catch (any e) {
			assertEquals("craft.InvalidArgumentException", e.type, "trying to watch a directory that does not exist should throw exception 'craft.InvalidArgumentException'")
		}
	}

	public void function WatchingExistingFile_Should_ThrowInvalidArgumentException() {
		try {
			variables.watcher = createWatcher(variables.directory & "nodir", false)
			variables.watcher.close()
			fail("trying to watch a directory that is not a directory should throw an exception")
		} catch (any e) {
			assertEquals("craft.InvalidArgumentException", e.type, "trying to watch a directory that is not a directory should throw exception 'craft.InvalidArgumentException'")
		}
	}

	public void function AfterCreatingFile_Watcher_Should_ReturnCreateEvent() {
		variables.watcher = createWatcher(variables.directory, false)

		FileWrite(variables.directory & "created.txt", "created")
		// due to the sleep calls the test will take about a minute
		Sleep(wait)
		var events = variables.watcher.poll()
		assertEquals(1, events.len(), "after creating a file, the watcher should return a single event when polled")
		assertEquals("ENTRY_CREATE", events[1].type, "after creating a file, the resulting event type should be 'ENTRY_CREATE'")
		assertEquals(variables.directory & "created.txt", ToString(events[1].file), "after creating a file, the file path should be the path of the created file")
	}

	public void function AfterDeletingFile_Watcher_Should_ReturnDeleteEvent() {
		variables.watcher = createWatcher(variables.directory, false)

		FileDelete(variables.directory & "delete.txt")
		Sleep(wait)
		var events = variables.watcher.poll()
		assertEquals(1, events.len(), "after deleting a file, the watcher should return a single event when polled")
		assertEquals("ENTRY_DELETE", events[1].type, "after deleting a file, the resulting event type should be 'ENTRY_DELETE'")
		assertEquals(variables.directory & "delete.txt", ToString(events[1].file), "after deleting a file, the file path should be the path of the deleted file")
	}

	public void function AfterModifyingFile_Watcher_Should_ReturnModifyEvent() {
		variables.watcher = createWatcher(variables.directory, false)

		FileWrite(variables.directory & "modify.txt", "modified")
		Sleep(wait)
		var events = variables.watcher.poll()
		assertEquals(1, events.len(), "after modifying a file, the watcher should return a single event when polled")
		assertEquals("ENTRY_MODIFY", events[1].type, "after modifying a file, the resulting event type should be 'ENTRY_MODIFY'")
		assertEquals(variables.directory & "modify.txt", ToString(events[1].file), "after modifying a file, the file path should be the path of the modified file")
	}

	public void function AfterRenamingFile_Watcher_Should_ReturnCreateAndDeleteEvent() {
		variables.watcher = createWatcher(variables.directory, false)

		FileMove(variables.directory & "rename.txt", variables.directory & "renamed.txt")
		Sleep(wait)
		var events = variables.watcher.poll()
		assertEquals(2, events.len(), "after renaming a file, the watcher should return 2 events when polled")
		var index = findEvent(events, "ENTRY_DELETE")
		assertTrue(index > 0, "after renaming a file, one of the resulting event types should be 'ENTRY_DELETE'")
		assertEquals(variables.directory & "rename.txt", ToString(events[index].file), "after renaming a file, the file path of the ENTRY_DELETE event should be the original path")
		var index = findEvent(events, "ENTRY_CREATE")
		assertTrue(index > 0, "after renaming a file, one of the resulting event types should be 'ENTRY_CREATE'")
		assertEquals(variables.directory & "renamed.txt", ToString(events[index].file), "after renaming a file, the file path of the ENTRY_CREATE event should be the new path")
	}

	public void function AfterClosing_Watcher_Should_ThrowExceptionWhenPolled() {
		variables.watcher = createWatcher(variables.directory, false)
		variables.watcher.close()
		try {
			var events = variables.watcher.poll()
			fail("polling a closed variables.watcher should throw an exception")
		} catch (any e) {
			assertEquals("java.nio.file.ClosedWatchServiceException", e.type, "polling a closed watcher should throw exception 'java.nio.file.ClosedWatchServiceException'");
		}
	}

	public void function AfterWritingInSubDir_Watcher_ShouldNot_ReturnEvents() {
		variables.watcher = createWatcher(variables.directory, false)

		FileWrite(variables.directory & "sub1/invisible.txt", "invisible")
		Sleep(wait)
		var events = variables.watcher.poll()
		// the directory sub1 may signal modification, ignore this
		for (var event in events) {
			if (event.file.isFile()) {
				fail("a non-recursive watcher should not signal changes in subdirectories")
			}
		}
	}

	public void function AfterWritingInSubDir_RecursiveWatcher_Should_ReturnEvents() {
		variables.watcher = createWatcher(variables.directory, true)

		FileWrite(variables.directory & "sub1/visible.txt", "visible")
		Sleep(wait)
		var events = variables.watcher.poll()
		assertEquals(1, events.len(), "after creating a file, the watcher should return a single event when polled")
		assertEquals("ENTRY_CREATE", events[1].type, "after creating a file, the resulting event type should be 'ENTRY_CREATE'")
		assertEquals(variables.directory & "sub1/visible.txt", ToString(events[1].file), "after creating a file, the file path should be the path of the created file")
	}

	public void function AfterCreatingDirectory_RecursiveWatcher_Should_WatchDirectory() {
		variables.watcher = createWatcher(variables.directory, true)

		DirectoryCreate(variables.directory & "sub2")
		Sleep(wait)
		var events = variables.watcher.poll()
		assertEquals(1, events.len(), "after creating a directory, the watcher should return a single event when polled")
		assertEquals("ENTRY_CREATE", events[1].type, "after creating a directory, the resulting event type should be 'ENTRY_CREATE'")
		assertEquals(variables.directory & "sub2", ToString(events[1].file), "after creating a directory, the directory path should be the path of the created directory")

		FileWrite(variables.directory & "sub2/visible.txt", "visible")
		Sleep(wait)
		var events = variables.watcher.poll()
		assertEquals(1, events.len(), "after creating a file, the watcher should return a single event when polled")
		assertEquals("ENTRY_CREATE", events[1].type, "after creating a file, the resulting event type should be 'ENTRY_CREATE'")
		assertEquals(variables.directory & "sub2/visible.txt", ToString(events[1].file), "after creating a file, the file path should be the path of the created file")

	}

	private DirectoryWatcher function createWatcher(required String directory, required Boolean recursive) {
		var watcher = new DirectoryWatcher(arguments.directory, arguments.recursive)
		Sleep(500) // sometimes the watcher needs a little time to start up
		return watcher
	}

	private Numeric function findEvent(required Array events, required String type) {
		var type = arguments.type
		return arguments.events.find(function (event) {
			return arguments.event.type == type
		})
	}

}