public with sharing class ReportRunnerController {
	
	public Id reportId {get; set;}
	public Boolean getDetails {get; set;}
	public String reportDebug {get; private set;}
	public Reports.ReportInstance instance;
	
	public ReportRunnerController()
	{
		getDetails = false;
	}
    
    public List<selectOption> getReportList()
    {
    	List<selectOption> retList = new List<selectOption>();
    	for(Report rep : [SELECT Id, Name FROM Report ORDER BY Name ASC LIMIT 50])
    	{
    		retList.add(new selectOption(rep.Id,rep.Name));
    	}
    	return retList;
    }
    
    public void runSync()
    {
    	reportDebug = '';
    	instance = null;
    	Reports.ReportResults results = ReportHelper.getReportSync(reportId,getDetails);
    	reportDebug = getDetails ? ReportHelper.debugSummaryReportData(results) : ReportHelper.debugDetailReportData(results);
    }
    
    public void runAsync()
    {
    	reportDebug = '';
    	instance = ReportHelper.getReportAsync(reportId,getDetails);
    	//reportDebug = getDetails ? ReportHelper.debugSummaryReportData(results) : ReportHelper.debugDetailReportData(results);
    }
    
    public void waitForAsync()
    {
    	if(instance != null)
    	{
    		if(instance.getStatus() == 'Success')
    		{
    			reportDebug = getDetails ? ReportHelper.debugSummaryReportData(instance.getReportResults()) 
    				: ReportHelper.debugDetailReportData(instance.getReportResults());
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
    				reportDebug = 'Report running...';
    			}
    		}
    	}
    }
    
    public void runAsyncCached()
    {
    	Reports.ReportResults results;
		List<Reports.ReportInstance> ris = Reports.ReportManager.getReportInstances(reportId);
		Integer lastOne = 0;
		
		// refresh if nothing found or last one older than an hour
		if(ris == null || ris.isEmpty() || ris.get(lastOne).getRequestDate() < Datetime.now().addHours(-1))
		{
    		runAsync();
		}
		else
		{
			results = ris.get(lastOne).getReportResults();
			Datetime reqDate = ris.get(lastOne).getRequestDate();
			reportDebug = getDetails ? ReportHelper.debugSummaryReportData(results) : ReportHelper.debugDetailReportData(results);
    		if(reqDate != null) reportDebug += '(Run @ ' + reqDate + ')\n';
		}
    }
    
    public Boolean getIsRunningReport()
    {
    	return instance != null;
    }
}