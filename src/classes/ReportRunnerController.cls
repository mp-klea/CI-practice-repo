public with sharing class ReportRunnerController {
	
	public Id reportId {get; set;}
	public Boolean retrieveDetails {get; set;}
	public String reportDebug {get; private set;}
	public Reports.ReportInstance instance;
	
	public ReportRunnerController()
	{
		retrieveDetails = false;
	}
    
    public List<selectOption> getReportList()
    {
    	List<selectOption> retList = new List<selectOption>();
    	for(Report rep : [SELECT Id, Name FROM Report ORDER BY Name ASC LIMIT 50])
    	{
    		retList.add(new selectOption(rep.Id,rep.Name));
    	}
    	reportId = (Id) retList.get(0).getValue();
    	return retList;
    }
    
    public void runSync()
    {
    	reportDebug = '';
    	instance = null;
    	Reports.ReportResults results = ReportHelper.getReportSync(reportId,retrieveDetails);
    	reportDebug = retrieveDetails ? ReportHelper.debugDetailReportData(results) : ReportHelper.debugSummaryReportData(results);
    }
    
    public void runAsync()
    {
    	reportDebug = '';
    	instance = ReportHelper.getReportAsync(reportId,retrieveDetails);
    	waitForAsync();
    }
    
    public void waitForAsync()
    {
    	if(instance != null)
    	{
    		if(instance.getStatus() == 'Success')
    		{
    			reportDebug = retrieveDetails ? ReportHelper.debugDetailReportData(instance.getReportResults()) 
    				: ReportHelper.debugSummaryReportData(instance.getReportResults());
    			instance = null;
    		}
    		else
    		{
    			if(instance.getStatus() == 'Error')
    			{
    				reportDebug = 'Report error.';
    				instance = null;
    			}
    			else
    			{
    				reportDebug = instance.getStatus() + '...';
    				instance = Reports.ReportManager.getReportInstance(instance.getId());	// refresh instance
    			}
    		}
    	}
    }
    
    public void runAsyncCached()
    {
    	instance = null;
    	
		List<Reports.ReportInstance> ris = Reports.ReportManager.getReportInstances(reportId);
		Integer lastOne = 0;
		
		// refresh if nothing found or last one older than an hour
		if(ris == null || ris.isEmpty() || ris.get(lastOne).getRequestDate() < Datetime.now().addHours(-1))
		{
    		runAsync();
		}
		else
		{
			Reports.ReportResults results = ris.get(lastOne).getReportResults();
			Datetime reqDate = ris.get(lastOne).getRequestDate();
			reportDebug = retrieveDetails ? ReportHelper.debugDetailReportData(results) : ReportHelper.debugSummaryReportData(results);
    		if(reqDate != null) reportDebug += '\n(Run @ ' + reqDate + ')';
		}
    }
    
    public Boolean getIsRunningReport()
    {
    	return instance != null;
    }
}