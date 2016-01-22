public with sharing class ReportHelper {
	
	// e.g. My_Opportunities_by_Type - 00Ob0000003vh81EAA
	
	public static Id getReportId(String reportDeveloperName)
	{
		// Get the report ID
		List <Report> reportList = [SELECT Id, DeveloperName FROM Report WHERE DeveloperName = :reportDeveloperName];
		String reportId = (String)reportList.get(0).get('Id');
		
		return reportId;
	}
	
	public static Reports.ReportResults getReportSync(Id reportId, Boolean getDeatils)
	{
		// set metadata config
		Reports.ReportDescribeResult describe = Reports.ReportManager.describeReport(reportId);
		Reports.ReportMetadata reportMd = describe.getReportMetadata();
		/*// set scope to whole organization
		reportMd.setScope('organization');
		// need to also set date filter fo current FQ
		Reports.StandardDateFilter sdf = reportMd.getStandardDateFilter();
		sdf.setStartDate('2016-01-01');
		sdf.setEndDate('2016-03-31');*/
		
		// Run the report
		Reports.ReportResults results = Reports.ReportManager.runReport(reportId, reportMD, getDeatils);
		return results;
	}
	
	public static void debugSummaryReportData(Reports.ReportResults results)
	{
		// Get the first down-grouping in the report
		Reports.Dimension dim = results.getGroupingsDown();
		
		//DEBUG - get horizontal groupings with their summaries
		for(Reports.GroupingValue groupingVal :  dim.getGroupings())
		{
			System.debug('Key: ' + groupingVal.getKey() + ', Label: ' + groupingVal.getLabel() + ', Value: ' +  groupingVal.getValue());
			String factMapKey = groupingVal.getKey() + '!T';
			// Get the fact map from the report results
			Reports.ReportFactWithSummaries factSummary = (Reports.ReportFactWithSummaries)results.getFactMap().get(factMapKey);
			for(Reports.SummaryValue sumVal : factSummary.getAggregates())
			{
				System.debug('Summary Value: ' + sumVal.getLabel());
			}
		}
		
		// Construct a fact map key, using the grouping key value
		//String factMapKey = groupingVal.getKey() + '!T';
		
		// Get the fact map from the report results
		//Reports.ReportFactWithDetails factDetails =
		//	//(Reports.ReportFactWithDetails)results.getFactMap().get(factMapKey);
		//Reports.ReportFactWithSummaries factSummary =
			//(Reports.ReportFactWithSummaries)results.getFactMap().get(factMapKey);
		
		// Get the first summary amount from the fact map
		//Reports.SummaryValue sumVal = factSummary.getAggregates()[0];
		//System.debug('Summary Value: ' + sumVal.getLabel());
		
		// Get the field value from the first data cell of the first row of the report
		//Reports.ReportDetailRow detailRow = factDetails.getRows()[0];
		//System.debug('DetailRow: ' + detailRow.getDataCells()[0].getLabel());
	}
	
	public static void describeReport(Id reportId)
	{
		Reports.ReportDescribeResult describe = Reports.ReportManager.describeReport(reportId);
		Reports.ReportMetadata reportMd = describe.getReportMetadata();  
		system.debug(reportMd);
	}
	
}