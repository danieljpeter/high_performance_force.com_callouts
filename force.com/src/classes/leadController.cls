public class leadController {

	public List<Lead> leadList {get;set;} 
	public Set<Id> leadIdSet {get;set;}
	
	public leadController() {
		leadList = new List<Lead>();
		leadList = [SELECT Id, FirstName, LastName, Company FROM Lead WHERE Company='North Bay DUG'];
		
		leadIdSet = new Set<Id>();
		for (Lead l : leadList) {
			leadIdSet.add(l.Id);	
		}			
	}

	public PageReference sendNative() {
		Id batchInstanceId = Database.executeBatch(new batchProcessCallouts(leadIdSet, 0, leadIdSet.size(), Datetime.now()), 10);
		return null;
	}

	public PageReference sendProxy() {
		String sJSON = JSON.serialize(leadIdSet);
		system.debug(sJSON);

	    HttpRequest req = new HttpRequest();
	    HttpResponse res = new HttpResponse();
	    Http http = new Http();
	
	    req.setEndpoint('http://some.proxy.com/proxy.php');
	    req.setMethod('POST');
	    req.setBody('leadIds='+EncodingUtil.urlEncode(sJSON, 'UTF-8'));
	    
	    res = http.send(req);		

		return null;
	}


}