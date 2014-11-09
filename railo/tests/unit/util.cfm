<cfscript>
	mapping = "tests.unit.util"
	testbox = new testbox.system.TestBox(directory = {
		mapping: mapping,
		recurse: false,
		filter: function (path) {
			var class = mapping & "." & arguments.path.listLast("/").listFirst(".")
			var metadata = GetComponentMetadata(class)
			return !(metadata.skip ?: false);
		}
	})

	WriteOutput(testbox.run());
</cfscript>