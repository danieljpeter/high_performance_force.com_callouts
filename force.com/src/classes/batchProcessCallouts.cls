global class batchProcessCallouts implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

	global Set<Id> leadIds;
	global Set<Id> leadIdRemaining;
	
	global Integer initialTotalSize;
	global Datetime startTime;
	global Integer batchCount;

	global batchProcessCallouts(Set<Id> leadIdsIn, Integer batchCountIn, Integer initialTotalSizeIn, Datetime startTimeIn) {
		leadIds = leadIdsIn;
		initialTotalSize = initialTotalSizeIn;
		startTime = startTimeIn;
		batchCount = batchCountIn;		
	}	

	global Database.QueryLocator start(Database.BatchableContext BC){
		/*
		take the full leadIds Set passed in (the remaining leads to be processed)
		and split it into 2 Sets.  

		leadIdCurrent: the first 10 Ids of the set (or less if there are > 10)
		leadIdRemaining: everything except the first 10 Ids of the set (nothing if there are <= 10)
		*/

		Set<Id> leadIdCurrent = new Set<Id>();
		leadIdRemaining = new Set<Id>();
		
		Integer chunkCount = 1;
        for(Id cId : leadIds) {
			if (chunkCount <= 10) {
				leadIdCurrent.add(cId);
			} else {
				leadIdRemaining.add(cId);
			} 			
			chunkCount ++;
        }
		
		//convert a set of IDs into a csv list
        String cIdCsv = '\'' ;
        for(Id cId : leadIdCurrent) {
			cIdCsv += cId + '\',\''; 			
        }
		cIdCsv = cIdCsv.removeEnd(',\'');
		
		
		String sQuery =		
		'SELECT Id, FirstName, LastName, Company ' + 
		'FROM lead ' + 
		'WHERE Id IN ('+cIdCsv+') ORDER BY LastName';	
		
		batchCount++;	
		
		return Database.getQueryLocator(sQuery);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope){
		
		for (sObject s : scope) {
			Lead l = (Lead)s;			
			
    		String postString = l.Id + ' *** ' + l.Firstname + ' *** ' + l.Lastname + ' *** ' + l.Company; 

		    HttpRequest req = new HttpRequest();
		    HttpResponse res = new HttpResponse();
		    Http http = new Http();
		
		    req.setEndpoint('http://some.webservice.com/listener.php');
		    req.setMethod('POST');
		    req.setBody('lead='+EncodingUtil.urlEncode(postString, 'UTF-8'));
		    
		    res = http.send(req);
		}		
	}


	global void finish(Database.BatchableContext BC){
		if (leadIdRemaining != null) {
			if (!leadIdRemaining.isEmpty()) {
				//fire again
				Id batchInstanceId = Database.executeBatch(new batchProcessCallouts(leadIdRemaining, batchCount, initialTotalSize, startTime), 10);
			} else {
				//we are done

				
				//=========== generate completion / error msg
				String sMsg = 'Batch Sent.\n\n';
				
				sMsg += 'Total leads Sent: ' + initialTotalSize.format() + '\n';
				sMsg += 'Number of Batches: ' + batchCount.format() + '\n';
				sMsg += 'Start Time PST: ' + startTime.format('MM/dd/yyyy HH:mm:ss', 'America/Los_Angeles') + '\n';
				sMsg += 'End Time PST: ' + Datetime.now().format('MM/dd/yyyy HH:mm:ss', 'America/Los_Angeles') + '\n';
				sMsg += 'Number of Seconds: ' + ((Datetime.now().getTime() - startTime.getTime()) / 1000) + '\n';
				//=========== end generate completion / error msg		
				
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		
				mail.setToAddresses(new String[] {'northbaydug@gmail.com'});
				mail.setReplyTo('batch@salesforce.com');
				mail.setSenderDisplayName('salesforce');
				mail.setSubject('Email Batch Sent');
				mail.setPlainTextBody(sMsg);
		
				Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
				

								
			}
					
		}
		
		
	}



}