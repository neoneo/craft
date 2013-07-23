<cfscript>
	test = new util.DirectoryWatcherTest()
	test.beforeTests()
	test.setUp()
	test.AfterWritingInSubDir_Watcher_ShouldNot_ReturnEvents()

	test.tearDown()
	test.afterTests()

</cfscript>