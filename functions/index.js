const functions = require('firebase-functions');
const admin = require('firebase-admin');
const sgMail = require('@sendgrid/mail');

admin.initializeApp();
const db = admin.firestore();

// Set your SendGrid API key from environment config
const SENDGRID_API_KEY = functions.config().sendgrid.key;
sgMail.setApiKey(SENDGRID_API_KEY);

exports.sendEmailReminders = functions.pubsub
  .schedule('0 6 * * *')  
  .timeZone('Africa/Accra')
  .onRun(async (context) => {
    const today = new Date();
    const dateOnly = new Date(today.getFullYear(), today.getMonth(), today.getDate());

    try {
      const groupsSnapshot = await db.collection('groups').get();

      for (const groupDoc of groupsSnapshot.docs) {
        const groupId = groupDoc.id;
        const groupName = groupDoc.data().name;
        const memberEmails = groupDoc.data().memberEmails || [];

        const eventsSnapshot = await db
          .collection('groups')
          .doc(groupId)
          .collection('events')
          .get();

        for (const eventDoc of eventsSnapshot.docs) {
          const eventData = eventDoc.data();
          const eventDate = eventData.date.toDate();
          const reminderDays = eventData.reminderDaysBefore || [];

          const daysUntilEvent = Math.ceil(
            (eventDate - dateOnly) / (1000 * 60 * 60 * 24)
          );

          if (reminderDays.includes(daysUntilEvent)) {
            for (const email of memberEmails) {
              const msg = {
                to: email,
                from: 'hannahmaamleyosae@hotmail.com',
                subject: `Reminder: ${eventData.title} coming up!`,
                html: `
                  <p>Hi there,</p>
                  <p>This is a reminder that <strong>${eventData.title}</strong> is happening in ${daysUntilEvent} day(s).</p>
                  <p><strong>Date:</strong> ${eventDate.toDateString()}<br />
                  <strong>Group:</strong> ${groupName}</p>
                  <p>Thanks,<br/>AutoPrompt Team</p>
                `,
              };

              await sgMail.send(msg);
            }
          }
        }
      }

      console.log('Reminders sent successfully.');
      return null;
    } catch (error) {
      console.error('Error sending reminders:', error);
    }
  });
