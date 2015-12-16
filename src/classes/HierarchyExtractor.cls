/*
 * Author:		Klea Kolaric
 * Date:		2015-12-16
 * Description:	Class to extract a hierarchy of objects
 *
 */
 
public with sharing class HierarchyExtractor {
	
	// EXAMPLE 1: object-specific extractor
	// PRO: easier to code
	// PRO: more efficient SOQL as it can use set instead of list of ids
	// PRO: more efficient if many memebers per hierarchy level
	// CON: not bulkified - to many levels will exceede SOQL limit
	// CON: not reusable for other objects
	
	// I included the Node class in the HierarchyExtractor to make the code more compact
	// but you can convert it to a top level class if needed for e.g. VF components
	
	public class objectNode
	{
		public Sobject parent;
		public List<Sobject> children;
		
		public objectNode(Sobject parent)
		{
			this.parent = parent;
			this.children = new List<Sobject>();
		}
	}
    
}