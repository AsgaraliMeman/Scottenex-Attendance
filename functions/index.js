const {setGlobalOptions} = require("firebase-functions");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

// Initialize Firebase Admin
admin.initializeApp();

// Set global options for cost control
setGlobalOptions({maxInstances: 10});

// Create email transporter using Gmail SMTP
// NOTE: Use Gmail App Password, not your regular password
// Generate at: https://myaccount.google.com/apppasswords
const emailTransporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.GMAIL_EMAIL || "your-email@gmail.com",
    pass: process.env.GMAIL_APP_PASSWORD || "your-app-password",
  },
});

/**
 * Send password reset email via Gmail
 */
async function sendPasswordResetEmail(
    recipientEmail,
    recipientName,
    resetLink,
) {
  try {
    const mailOptions = {
      from: `Scottenex Attendance <${process.env.GMAIL_EMAIL || "noreply@scottenex.com"}>`,
      to: recipientEmail,
      subject: "Password Reset Approved - Action Required",
      html: `
        <html>
          <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
            <div style="max-width: 600px; margin: 0 auto;">
              <h2 style="color: #2196F3;">Password Reset Approved</h2>
              
              <p>Hello <strong>${recipientName}</strong>,</p>
              
              <p>Your password reset request has been approved by the admin. Click the button below to set a new password:</p>
              
              <div style="margin: 30px 0;">
                <a href="${resetLink}" style="
                  display: inline-block;
                  background-color: #2196F3;
                  color: white;
                  padding: 12px 30px;
                  text-decoration: none;
                  border-radius: 4px;
                  font-weight: bold;
                  cursor: pointer;
                ">
                  Reset Password
                </a>
              </div>
              
              <p style="color: #666;">
                <strong>Or copy this link:</strong><br/>
                <code style="background-color: #f5f5f5; padding: 10px; border-radius: 4px; display: block; word-break: break-all;">
                  ${resetLink}
                </code>
              </p>
              
              <p style="color: #999; font-size: 12px; margin-top: 30px;">
                This link will expire in 24 hours. If you did not request a password reset, please contact the admin.
              </p>
              
              <hr style="border: none; border-top: 1px solid #ddd; margin: 20px 0;">
              
              <p style="color: #999; font-size: 12px;">
                Scottenex Attendance System
              </p>
            </div>
          </body>
        </html>
      `,
    };

    const info = await emailTransporter.sendMail(mailOptions);
    logger.info(`Email sent successfully to ${recipientEmail}`, {
      structuredData: true,
      messageId: info.messageId,
    });
    return info;
  } catch (error) {
    logger.error(`Error sending email to ${recipientEmail}: ${error.message}`, {
      structuredData: true,
      error: error.stack,
    });
    throw error;
  }
}

/**
 * Send push notification when password reset is approved
 * Triggers on any new notification created in the notifications collection
 */
exports.sendPasswordResetNotification = onDocumentCreated(
    "notifications/{userId}/messages/{messageId}",
    async (event) => {
      try {
        const notificationData = event.data.data();
        const userId = event.params.userId;

        logger.info(`Processing notification for user: ${userId}`, {
          structuredData: true,
          notificationType: notificationData.type,
        });

        // Only send push notification for password reset approvals
        if (notificationData.type !== "password_reset_approved") {
          logger.info("Skipping non-password-reset notification");
          return;
        }

        // Get user's FCM token from Firestore
        const userDoc = await admin
            .firestore()
            .collection("users")
            .doc(userId)
            .get();

        if (!userDoc.exists) {
          logger.warn(`User document not found: ${userId}`);
          return;
        }

        const fcmToken = userDoc.data().fcmToken;

        if (!fcmToken) {
          logger.warn(`No FCM token found for user: ${userId}`);
          return;
        }

        // Prepare the notification payload for all platforms
        const payload = {
          notification: {
            title: notificationData.title || "Password Reset Approved",
            body:
                        notificationData.message ||
                        "Your password reset request has been approved.",
            clickAction: "FLUTTER_NOTIFICATION_CLICK",
          },
          data: {
            type: "password_reset_approved",
            resetLink: notificationData.resetLink || "",
            recipientEmail: notificationData.recipientEmail || "",
            recipientName: notificationData.recipientName || "",
            notificationId: event.params.messageId,
          },
          android: {
            priority: "high",
            notification: {
              clickAction: "FLUTTER_NOTIFICATION_CLICK",
              sound: "default",
              channelId: "password_reset",
            },
          },
          apns: {
            headers: {
              "apns-priority": "10",
            },
            payload: {
              aps: {
                "alert": {
                  title: notificationData.title ||
                    "Password Reset Approved",
                  body: notificationData.message ||
                    "Your password reset request has " +
                    "been approved.",
                },
                "sound": "default",
                "badge": 1,
                "mutable-content": 1,
              },
            },
          },
          webpush: {
            notification: {
              title: notificationData.title ||
                "Password Reset Approved",
              body: notificationData.message ||
                "Your password reset request has " +
                "been approved.",
              icon: "https://via.placeholder.com/192",
              badge: "https://via.placeholder.com/192",
              tag: "password_reset_approved",
              requireInteraction: true,
            },
            data: {
              type: "password_reset_approved",
              resetLink: notificationData.resetLink || "",
              recipientEmail: notificationData.recipientEmail || "",
              clickAction: "https://scottenex-attendance.firebaseapp.com",
            },
          },
        };

        // Send the notification to all devices with this token
        const response = await admin.messaging().send({
          ...payload,
          token: fcmToken,
        });

        // Send email notification with reset link
        try {
          await sendPasswordResetEmail(
              notificationData.recipientEmail,
              notificationData.recipientName,
              notificationData.resetLink,
          );
          logger.info(`Password reset email sent to ${notificationData.recipientEmail}`, {
            structuredData: true,
          });
        } catch (emailError) {
          logger.warn(`Email send failed but push notification was sent: ${emailError.message}`, {
            structuredData: true,
          });
          // Continue - push notification was already sent successfully
        }

        logger.info(`Notification sent successfully: ${response}`, {
          structuredData: true,
          userId: userId,
          fcmToken: fcmToken.substring(0, 20) + "...",
        });

        return response;
      } catch (error) {
        logger.error(`Error sending notification: ${error.message}`, {
          structuredData: true,
          error: error.stack,
        });
        throw error;
      }
    },
);

/**
 * Send notifications to multiple users (for broadcast notifications)
 * Example: Admin approves password reset for multiple employees
 */
exports.sendBroadcastNotification = onDocumentCreated(
    "notifications_broadcast/{broadcastId}",
    async (event) => {
      try {
        const broadcastData = event.data.data();
        const userIds = broadcastData.userIds || [];

        logger.info(`Broadcasting notification to ${userIds.length} users`, {
          structuredData: true,
        });

        // Get FCM tokens for all users
        const tokensSnapshot = await admin
            .firestore()
            .collection("users")
            .where("__name__", "in", userIds)
            .get();

        const tokens = [];
        tokensSnapshot.forEach((doc) => {
          if (doc.data().fcmToken) {
            tokens.push(doc.data().fcmToken);
          }
        });

        if (tokens.length === 0) {
          logger.warn("No FCM tokens found for broadcast");
          return;
        }

        const payload = {
          notification: {
            title: broadcastData.title || "Notification",
            body: broadcastData.body || "You have a new notification",
          },
          data: {
            type: broadcastData.type || "broadcast",
            deepLink: broadcastData.deepLink || "",
          },
        };

        // Send to all tokens
        const response = await admin.messaging().sendMulticast({
          ...payload,
          tokens: tokens,
        });

        logger.info(
            `Broadcast sent to ${response.successCount} devices, ` +
                `${response.failureCount} failed`,
            {
              structuredData: true,
            },
        );

        return response;
      } catch (error) {
        logger.error(`Error sending broadcast notification: ${error.message}`, {
          structuredData: true,
          error: error.stack,
        });
        throw error;
      }
    },
);
