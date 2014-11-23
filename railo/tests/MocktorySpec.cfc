import craft.content.*;
import craft.framework.*;
import craft.markup.*;
import craft.output.*;
import craft.request.*;
import craft.util.*;

component extends="testbox.system.BaseSpec" {

	function beforeAll() {
		$mocktory = new Mocktory($mockbox, function (name) {
			return GetComponentMetadata(arguments.name).name;
		})
	}

	function mock(required Any descriptor) {
		return $mocktory.mock(arguments.descriptor);
	}

	function verify(required Any mockObject, Struct descriptor) {
		$mocktory.verify(argumentCollection = arguments)
	}

}