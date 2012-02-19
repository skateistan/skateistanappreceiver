
// Submit a remote volunteer application to skateistanappreceiver

function sendRemoteVolunteerApplication() {
  var hook_url = 'http://skateistanappreceiver.heroku.com/rva/'; // 'http://postbin.heroku.com/e4d6efc8'
  var ss = SpreadsheetApp.openById('0AluR35QKrj23dHpXU2ZVRkxHUzJDV1R6Y0wxbEstWmc');
  var form = ss.getSheets()[0];
  var lr = form.getLastRow();
  var data = form.getRange(lr, 2, 1, 9).getValues();
  
  var payload = {
    "name" : data[0][0],
    "email" : data[0][2]
  };

  // Send the application
  var x = UrlFetchApp.fetch(hook_url, { method: 'post', payload: payload });
}