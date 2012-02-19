
// Submit a remote volunteer application to skateistanappreceiver

function sendRemoteVolunteerApplication() {
  var hook_url = 'http://skateistanappreceiver.heroku.com/rva/';
  var ss = SpreadsheetApp.openById('0AluR35QKrj23dHpXU2ZVRkxHUzJDV1R6Y0wxbEstWmc');
  var form = ss.getSheets()[0];
  var lr = form.getLastRow();
  var data = form.getRange(lr, 2, 1, 10).getValues();
  
  var payload = {
    "firstname" : data[0][0],
    "lastname" : data[0][1],
    "email" : data[0][3]
  };

  // Send the application
  var x = UrlFetchApp.fetch(hook_url, { method: 'post', payload: payload });
}