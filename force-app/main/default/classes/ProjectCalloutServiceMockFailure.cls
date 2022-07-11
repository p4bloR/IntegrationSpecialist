global class ProjectCalloutServiceMockFailure implements HttpCalloutMock{
   //Implement http mock callout failure here
   global HTTPResponse respond(HTTPRequest req) {
      HttpResponse response = new HttpResponse();
      response.setHeader('Content-Type', 'application/json');
      response.setStatusCode(500);
      response.setStatus('ERROR');

      return response;
  }  
}