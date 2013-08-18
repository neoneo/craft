import craft.core.util.CacheBranchList;

component extends="PathSegment" {

	setChildCollection(new CacheBranchList(this))

}