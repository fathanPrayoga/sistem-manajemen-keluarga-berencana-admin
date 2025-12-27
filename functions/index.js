/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");

admin.initializeApp();

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

const {
    onDocumentUpdated,
} = require("firebase-functions/v2/firestore");

exports.sendComplaintStatusNotification = onDocumentUpdated(
    {
        document: "complaints/{complaintId}",
        region: "asia-southeast2",
    },
    async (event) => {
        const change = event.data;
        const beforeData = change.before.data();
        const afterData = change.after.data();

        // Check if status has changed
        if (beforeData.status === afterData.status) {
            return null;
        }

        const userId = afterData.userId;
        if (!userId) {
            logger.warn("No userId found in complaint document", {
                complaintId: event.params.complaintId,
            });
            return null;
        }

        try {
            // Get user's FCM token
            const userSnapshot = await admin
                .firestore()
                .collection("users")
                .doc(userId)
                .get();

            if (!userSnapshot.exists) {
                logger.warn("User not found", { userId });
                return null;
            }

            const userData = userSnapshot.data();
            const fcmToken = userData.fcmToken;

            if (!fcmToken) {
                logger.info("No FCM token for user", { userId });
                return null;
            }

            // Prepare notification
            const message = {
                notification: {
                    title: "Update Status Pengaduan",
                    body: `Status pengaduan Anda telah diperbarui menjadi: ${afterData.status}`,
                },
                token: fcmToken,
                data: {
                    complaintId: event.params.complaintId,
                    status: afterData.status,
                    click_action: "FLUTTER_NOTIFICATION_CLICK",
                },
            };

            // Send message
            const response = await admin.messaging().send(message);
            logger.info("Notification sent successfully", {
                response,
                userId,
                complaintId: event.params.complaintId,
            });
            return response;
        } catch (error) {
            logger.error("Error sending notification", error);
            return null;
        }
    },
);
