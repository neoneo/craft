import craft.util.gateway.DirectoryWatcher;

component extends="mxunit.framework.TestCase" {

	public void function setUp() {
		this.watcher = null
		this.directory = Replace(GetTempDirectory(), "\", "/", "all") & CreateGUID()
		DirectoryCreate(this.directory)
		DirectoryCreate(this.directory & "/sub1") // create a subdirectory for recursive tests
		// create some files for the tests
		FileWrite(this.directory & "/nodir", "nodir")
		FileWrite(this.directory & "/delete.txt", "delete")
		FileWrite(this.directory & "/modify.txt", "modify")
		FileWrite(this.directory & "/rename.txt", "rename")

		this.wait = 10100 // the watcher checks once every 10 seconds
	}

	public void function tearDown() {
		if (this.watcher !== null) {
			this.watcher.close()
		}
		DirectoryDelete(this.directory, true)
	}

	public void function WatchingNonExistingDirectory_Should_ThrowInvalidArgumentException() {
		try {
			this.watcher = createWatcher(this.directory & "0", false)
			this.watcher.close()
			fail("trying to watch a directory that does not exist should throw an exception")
		} catch (FileNotFoundException e) {}
	}

	public void function WatchingExistingFile_Should_ThrowInvalidArgumentException() {
		try {
			this.watcher = createWatcher(this.directory & "/nodir", false)
			this.watcher.close()
			fail("trying to watch a directory that is not a directory should throw an exception")
		} catch (FileNotFoundException e) {}
	}

	public void function AfterCreatingFile_Watcher_Should_ReturnCreateEvent() {
		this.watcher = createWatcher(this.directory, false)

		FileWrite(this.directory & "/created.txt", "created")
		// due to the sleep calls the test will take about a minute
		Sleep(wait)
		var events = this.watcher.poll()
		assertEquals(1, events.len(), "after creating a file, the watcher should return a single event when polled")
		assertEquals("ENTRY_CREATE", events[1].type, "after creating a file, the resulting event type should be 'ENTRY_CREATE'")
		assertEquals(this.directory & "/created.txt", ToString(events[1].file), "after creating a file, the file path should be the path of the created file")
	}

	public void function AfterDeletingFile_Watcher_Should_ReturnDeleteEvent() {
		this.watcher = createWatcher(this.directory, false)

		FileDelete(this.directory & "/delete.txt")
		Sleep(wait)
		var events = this.watcher.poll()
		assertEquals(1, events.len(), "after deleting a file, the watcher should return a single event when polled")
		assertEquals("ENTRY_DELETE", events[1].type, "after deleting a file, the resulting event type should be 'ENTRY_DELETE'")
		assertEquals(this.directory & "/delete.txt", ToString(events[1].file), "after deleting a file, the file path should be the path of the deleted file")
	}

	public void function AfterModifyingFile_Watcher_Should_ReturnModifyEvent() {
		this.watcher = createWatcher(this.directory, false)

		FileWrite(this.directory & "/modify.txt", "modified")
		Sleep(wait)
		var events = this.watcher.poll()
		assertEquals(1, events.len(), "after modifying a file, the watcher should return a single event when polled")
		assertEquals("ENTRY_MODIFY", events[1].type, "after modifying a file, the resulting event type should be 'ENTRY_MODIFY'")
		assertEquals(this.directory & "/modify.txt", ToString(events[1].file), "after modifying a file, the file path should be the path of the modified file")
	}

	public void function AfterRenamingFile_Watcher_Should_ReturnCreateAndDeleteEvent() {
		this.watcher = createWatcher(this.directory, false)

		FileMove(this.directory & "/rename.txt", this.directory & "/renamed.txt")
		Sleep(wait)
		var events = this.watcher.poll()
		assertEquals(2, events.len(), "after renaming a file, the watcher should return 2 events when polled")
		var index = findEvent(events, "ENTRY_DELETE")
		assertTrue(index > 0, "after renaming a file, one of the resulting event types should be 'ENTRY_DELETE'")
		assertEquals(this.directory & "/rename.txt", ToString(events[index].file), "after renaming a file, the file path of the ENTRY_DELETE event should be the original path")
		var index = findEvent(events, "ENTRY_CREATE")
		assertTrue(index > 0, "after renaming a file, one of the resulting event types should be 'ENTRY_CREATE'")
		assertEquals(this.directory & "/renamed.txt", ToString(events[index].file), "after renaming a file, the file path of the ENTRY_CREATE event should be the new path")
	}

	public void function AfterClosing_Watcher_Should_ThrowExceptionWhen_Polled() {
		this.watcher = createWatcher(this.directory, false)
		this.watcher.close()
		try {
			var events = this.watcher.poll()
			fail("polling a closed watcher should throw an exception")
		} catch (java.nio.file.ClosedWatchServiceException e) {}
	}

	public void function AfterWritingInSubDir_Watcher_ShouldNot_ReturnEvents() {
		this.watcher = createWatcher(this.directory, false)

		FileWrite(this.directory & "/sub1/invisible.txt", "invisible")
		Sleep(wait)
		var events = this.watcher.poll()
		// the directory sub1 may signal modification, ignore this
		for (var event in events) {
			if (event.file.isFile()) {
				fail("a non-recursive watcher should not signal changes in subdirectories")
			}
		}
	}

	public void function AfterWritingInSubDir_RecursiveWatcher_Should_ReturnEvents() {
		this.watcher = createWatcher(this.directory, true)

		FileWrite(this.directory & "/sub1/visible.txt", "visible")
		Sleep(wait)
		var events = this.watcher.poll()
		assertEquals(1, events.len(), "after creating a file, the watcher should return a single event when polled")
		assertEquals("ENTRY_CREATE", events[1].type, "after creating a file, the resulting event type should be 'ENTRY_CREATE'")
		assertEquals(this.directory & "/sub1/visible.txt", ToString(events[1].file), "after creating a file, the file path should be the path of the created file")
	}

	public void function AfterCreatingDirectory_RecursiveWatcher_Should_WatchDirectory() {
		this.watcher = createWatcher(this.directory, true)

		DirectoryCreate(this.directory & "/sub2")
		Sleep(wait)
		var events = this.watcher.poll()
		assertEquals(1, events.len(), "after creating a directory, the watcher should return a single event when polled")
		assertEquals("ENTRY_CREATE", events[1].type, "after creating a directory, the resulting event type should be 'ENTRY_CREATE'")
		assertEquals(this.directory & "/sub2", ToString(events[1].file), "after creating a directory, the directory path should be the path of the created directory")

		FileWrite(this.directory & "/sub2/visible.txt", "visible")
		Sleep(wait)
		var events = this.watcher.poll()
		assertEquals(1, events.len(), "after creating a file, the watcher should return a single event when polled")
		assertEquals("ENTRY_CREATE", events[1].type, "after creating a file, the resulting event type should be 'ENTRY_CREATE'")
		assertEquals(this.directory & "/sub2/visible.txt", ToString(events[1].file), "after creating a file, the file path should be the path of the created file")

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