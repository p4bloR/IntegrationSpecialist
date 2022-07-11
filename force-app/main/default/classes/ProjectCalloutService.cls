public class ProjectCalloutService {

    
    //Complete the implementation for business and callout logic
    @InvocableMethod(label='Post Opportuinity to PMS' description='Posts Opportunity objects to PMS after theyre updated')
	public static void postOpportunityToPMS(List<Id> oppIds){
        
        Opportunity o = [SELECT Id, Name, Account.name, CloseDate, Amount FROM Opportunity WHERE Id = :oppIds[0]];
        String TOKEN = ServiceTokens__c.getValues('ProjectServiceToken').Token__c;
        //String TOKEN = 	ServiceTokens__c.getInstance('ProjectServiceToken').Token__c;
        String jsonInput = '{\n' + 
        '"opportunityId" : ' + o.Id + ',\n' +
        '"opportunityName" : ' + o.Name + ',\n' +
        '"accountName" : ' + o.Account.Name + ',\n' +
        '"closeDate" : ' + String.valueOf(o.CloseDate) + ',\n' +
        '"amount" : ' + o.Amount + ',\n' +
        '"\n}';
        
        //ID jobID =
        System.enqueueJob(new QueueablePMSCall(token, o, jsonInput));
    }


    public with sharing class QueueablePMSCall implements Queueable, Database.AllowsCallouts{
    
        String token;
        Opportunity opp;
        String jsonInput;
    
        public QueueablePMSCall(String token, Opportunity opp, String jsonInput){
            this.token = token;
            this.opp = opp;
            this.jsonInput = jsonInput;
        }
    
        public void execute(QueueableContext context) {
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:ProjectService');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('token', token);
            request.setBody(this.jsonInput);
            HttpResponse response = http.send(request);
            
            // Parse the JSON response
            if(response.getStatusCode() == 201) {
                System.debug('Call was succesful, status: ' + response.getStatusCode() + ' ' + response.getStatus());
                //If the call is successful, set the opportunity Stage to Submitted Project
                opp.StageName = 'Submitted Project';
            } else if (response.getStatusCode() == 500) {
                //if it’s not successful, set it to Resubmit Project,
                System.debug('Call was not succesful, try to resubmit');
                opp.StageName = 'Resubmit Project';
            } else {
                System.debug('Call was not successful ' + response.getStatusCode() + ' ' + response.getStatus());
                System.debug(response.getBody());
            }
            
            update opp;
        }
    }    

}
