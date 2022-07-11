@isTest
private class ProjectCalloutServiceTest {

  @TestSetup
  static void generateData(){

    ServiceTokens__c token = new ServiceTokens__c();
    token.Name = 'ProjectServiceToken';
    token.Token__c = 'lala';
    insert token;
    //token.Name = ProjectCalloutService.TOKEN;
    //token.Token__c = 'TestToken';
    //insert token;
        
    Account acc = new Account();
    acc.Name = 'Test account';

    insert acc;

    Date tomorrow = system.today().addDays(1);

    Opportunity opp = new Opportunity();
    opp.Name = 'Test name';
    opp.Account = acc;
    opp.CloseDate = tomorrow;
    opp.Amount = 500.0;
    opp.StageName = 'Closed Won';

    insert opp;
  }
  //Implement mock callout tests here
  @isTest static void testPostOpportunityToPMSSuccess(){
    List<Opportunity> oppList = [SELECT Id, StageName FROM Opportunity WHERE Name = 'Test name' LIMIT 1];
    List<Id> idList = new List<Id>();
    for(Opportunity o : oppList){
      idList.add(o.Id);
    }

    String expectedInitialStageName = 'Closed Won';
    System.assertEquals(expectedInitialStageName, oppList[0].StageName);
    System.debug(oppList[0].StageName);
    Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMock()); 
    
    Test.startTest();
    ProjectCalloutService.postOpportunityToPMS(idList);
    Integer callouts = Limits.getCallouts();
    Test.stopTest();
    
    List<Opportunity> oppListAfter = [SELECT Id, StageName FROM Opportunity WHERE Id = :idList[0] LIMIT 1];
    String expectedStageName = 'Submitted Project';
    String actualStageName =  oppListAfter[0].StageName;
    System.assertEquals(expectedStageName, oppListAfter[0].StageName);
    System.debug(actualStageName);
  }

  @isTest static void testPostOpportunityToPMSFailure(){

    List<Opportunity> oppList = [SELECT Id, StageName FROM Opportunity WHERE Name = 'Test name' LIMIT 1];
    List<Id> idList = new List<Id>();
    for(Opportunity o : oppList){
      idList.add(o.Id);
    }

    String expectedInitialStageName = 'Closed Won';
    System.assertEquals(expectedInitialStageName, oppList[0].StageName);
    System.debug(oppList[0].StageName);
    Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMockFailure());
        
    Test.startTest();
    ProjectCalloutService.postOpportunityToPMS(idList);
    Test.stopTest();
    
    List<Opportunity> oppListAfter = [SELECT Id, StageName FROM Opportunity WHERE Id = :idList[0] LIMIT 1];
    String expectedStageName = 'Resubmit Project';
    String actualStageName =  oppListAfter[0].StageName;
    System.assertEquals(expectedStageName, oppListAfter[0].StageName);
    System.debug(actualStageName);    
  }

}

