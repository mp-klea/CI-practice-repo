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
	
	public static List<accountNode> extractAccountHierarchy()
	{
		// all these lists and maps reference the same place in memory, acting like pointers in C++
		List<accountNode> accountTree = new List<accountNode>();
		Map<Id,accountNode> levelParentMap = new Map<Id,accountNode>{null => null};	// we will first fetch top level parent
		
		while(!levelParentMap.isEmpty())
		{
			List<Account> levelChildList = [select id, Name, ParentId from Account where ParentId in :levelParentMap.keySet() order by Name asc];
			Map<Id,accountNode> nextLevelParentMap = new Map<Id,accountNode>();
			
			for(Account acc : levelChildList)
			{
				accountNode child = new  accountNode(acc);
				nextLevelParentMap.put(acc.Id,child);
				
				if(acc.ParentId != null)
				{
					levelParentMap.get(acc.ParentId).children.add(child);	// get parent and give them the child
				}
				else
				{
					accountTree.add(child);	// top level parents need to go into return list as "roots"
				}
			}
			levelParentMap = nextLevelParentMap; 	// children become parents in next iteration
		}
		return accountTree;
	}
	
	// I included the Node class in the HierarchyExtractor to make the code more compact
	// but you can convert it to a top level class if needed for e.g. VF components
	
	// generic object class
	public class objectNode
	{
		public Sobject parent {get; private set;}
		public List<objectNode> children {get; private set;}
		
		public objectNode(Sobject parent)
		{
			this.parent = parent;
			this.children = new List<objectNode>();
		}
		
		public objectNode() {}
	}
	
	// specific object class
	public class accountNode
	{
		public Account parent {get; private set;}
		public List<accountNode> children {get; private set;}
		
		public accountNode(Account parent)
		{
			this.parent = parent;
			this.children = new List<accountNode>();
		}
		
		public accountNode() {}
	}    
}