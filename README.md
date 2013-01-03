# skateistanappreceiver

Skateistan receives intern/remote volunteer applications via its Drupal-powered website.

Skateistan uses Highrise to manage all contacts including all intern/remote volunteer applicants, and also uses Campaign Monitor to manage subscribers for a variety of different email communications.

This Sinatra app receives intern/remote volunteer applications from the Skateistan website and does the following: 

- Uses the Highrise API to create contacts in Highrise
- Uses the Campaign Monitor API to add subscribers in Campaign Monitor
