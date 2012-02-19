
// Submit a remote volunteer application to skateistanappreceiver

function sendHRNotificationEmail(url, payload) {
  var toAddress = 'james@skateistan.org'; //'hr@skateistan.org';
  var subject = 'Remote Volunteer Application';
  var message = 'Remote Volunteer Application:\n\n';
  message += 'Applicant has been saved in Highrise: ' + url + '\n';

  MailApp.sendEmail(
    toAddress,
    subject,
    message,
    { name: 'Skateistan', replyTo: 'hr@skateistan.org' });
}

function sendConfirmationEmail(payload) {
  var subject = 'Thanks for your interest in Skateistan';
  var message = 'Hello,\n\n';
  message += 'Thanks for your interest in Skateistan. This is an automated response to let you know ';
  message += 'your application has been received. If you fit our profile we will get back to you as ';
  message += 'soon as possible. Only selected applicants will be contacted.\n\n';
  message += 'Chance khub!\n\n';
  message += '- The Skateistan Team';

  MailApp.sendEmail(
    payload.email,
    subject,
    message,
    { name: 'Skateistan', replyTo: 'hr@skateistan.org' });
}

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
  var response = UrlFetchApp.fetch(hook_url, { method: 'post', payload: payload });
  var url = response.getContentText();
  
  sendConfirmationEmail(payload);
  sendHRNotificationEmail(url, payload);
}