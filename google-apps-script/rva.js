
// Submit a remote volunteer application to skateistanappreceiver

function sendHRNotificationEmail(url, payload) {
  var toAddress = 'james@skateistan.org'; //'hr@skateistan.org';
  var subject = 'Remote Volunteer Application';
  var message = 'Remote Volunteer Application submitted by ' + payload.firstname + ' ' + payload.lastname + ':\n\n';
  message += 'Applicant has been saved in Highrise: ' + url + '\n\n';
  message += payload.note + "\n";

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
  
  var note = "Remote Volunteer Application: \n\n";
  note += "Name: " + data[0][0] + " " + data[0][1] + "\n\n";
  note += "Email: " + data[0][3] + "\n\n";
  note += "Address:\n" + data[0][4] + "\n\n";
  note += "Age: " + data[0][2] + "\n\n";
  note += "Are you a skateboarder? " + data[0][5] + "\n\n";
  note += "Why are you interested in the Skateistan project?\n" + data[0][6] + "\n\n";
  note += "How could you help Skateistan from your current location?\n" + data[0][7] + "\n\n";
  note += "How many hours a week could you to dedicate to a remote volunteer position?\n" + data[0][8] + "\n\n";
  note += "How many months could you potentially dedicate to a remote volunteer position?\n" + data[0][9] + "\n";
  
  var payload = {
    "firstname" : data[0][0],
    "lastname" : data[0][1],
    "email" : data[0][3],
    "note" : note
  };

  // Send the application
  var response = UrlFetchApp.fetch(hook_url, { method: 'post', payload: payload });
  var url = response.getContentText(); // Expected to be: https://skateistan.highrisehq.com/people/{id}
  sendConfirmationEmail(payload);
  sendHRNotificationEmail(url, payload);
}