import craft.framework.*;

import craft.util.*;

component extends="ContentFactory" accessors="true" {

	// Allow mocks to be injected for some instance variables.
	property ClassFinder componentFinder;
	property ObjectHelper objectHelper;

}