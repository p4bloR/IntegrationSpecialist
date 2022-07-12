@isTest
private class ProjectRESTServiceTest {
  //Implement Apex REST service tests here
  @TestSetup
  static void makeData(){
    Account acc = new Account();
    acc.Name = 'Test Account';
    insert acc;

    Opportunity opp = new Opportunity();
    opp.Account = acc;
    opp.Name = 'Opportunity Name';
    opp.Type = 'New Project';
    opp.StageName = 'Submitted Project';
    opp.Amount = 500.0;
    opp.CloseDate = Date.today();
    opp.DeliveryInstallationStatus__c = 'Yet to begin';
    insert opp;
  }
  
  @isTest
  static void testProjectRestServiceSuccess(){
    Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Opportunity Name' LIMIT 1];

    RestRequest request = new RestRequest();
    request.httpMethod = 'POST';
    request.requestURI = '/services/apexrest/project';
    RestContext.request = request;

    Test.startTest();
    String res = ProjectRESTService.postProjectData(
                                        'Reference', 
                                        'Test Project', 
                                        opp.Id, 
                                        Date.today(), 
                                        Date.today().addDays(3), 
                                        1000, 
                                        'Billable');

    Test.stopTest();
    
    System.assertEquals('OK', res);
    Project__c p = [SELECT Id, ProjectRef__c, Name, Opportunity__c, Start_Date__c, End_Date__c, Billable_Amount__c, Status__c FROM Project__c WHERE Name = 'Test Project' LIMIT 1];
    
    System.assertEquals('Reference', p.ProjectRef__c);
    System.assertEquals('Test Project', p.Name);
    System.assertEquals(opp.Id, p.Opportunity__c);
    System.assertEquals(Date.today(), p.Start_Date__c);
    System.assertEquals(Date.today().addDays(3), p.End_Date__c);
    System.assertEquals(1000, p.Billable_Amount__c);
    System.assertEquals('Billable', p.Status__c);

    Opportunity o = [SELECT Id, DeliveryInstallationStatus__c FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
    System.assertEquals('In progress', o.DeliveryInstallationStatus__c);
    
    
  }
  
  @isTest
  static void testProjectRestServiceFailure(){
    
    //Give an Id from an account instead of Opportunity to make it fail
    Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
    
    RestRequest request = new RestRequest();
    request.httpMethod = 'POST';
    request.requestURI = '/services/apexrest/project';
    RestContext.request = request;
    
    Test.startTest();
    String res = ProjectRESTService.postProjectData(
                                        'Reference', 
                                        'Test Project', 
                                        acc.Id, 
                                        Date.today(), 
                                        Date.today().addDays(3), 
                                        1000, 
                                        'Billable');
      Test.stopTest();
      
      List<Project__c> p = [SELECT Id, ProjectRef__c, Name, Opportunity__c, Start_Date__c, End_Date__c, Billable_Amount__c, Status__c FROM Project__c WHERE Name = 'Test Project' LIMIT 1];
      
      System.assertEquals(0, p.size());
      Opportunity opp = [SELECT Id, DeliveryInstallationStatus__c FROM Opportunity WHERE Name = 'Opportunity Name' LIMIT 1];
      System.assertNotEquals('In progress', opp.DeliveryInstallationStatus__c);
    }

}