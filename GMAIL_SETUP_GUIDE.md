# Gmail Setup for Password Reset Email Notifications

This guide explains how to set up Gmail to send password reset emails through the Firebase Cloud Function.

## Step 1: Enable 2-Factor Authentication on Gmail

1. Go to [myaccount.google.com](https://myaccount.google.com)
2. Click **Security** on the left sidebar
3. Under "How you sign in to Google", enable **2-Step Verification**
4. Follow the prompts to complete the setup

## Step 2: Create an App Password

1. Go to [myaccount.google.com/apppasswords](https://myaccount.google.com/apppasswords)
2. Select:
   - **App**: Mail
   - **Device**: Windows Computer (or your device)
3. Google will generate a 16-character password
4. **Copy this password** - you'll need it for the next step

## Step 3: Set Firebase Functions Environment Variables

Run these commands in your project root:

```bash
firebase functions:config:set gmail.email="your-email@gmail.com" gmail.password="your-16-char-app-password"
```

**Example:**
```bash
firebase functions:config:set gmail.email="admin@scottenex.com" gmail.password="abcd efgh ijkl mnop"
```

## Step 4: Update .env.local (Local Development)

If testing locally with emulator, create `.env.local` in the `functions/` directory:

```
GMAIL_EMAIL=your-email@gmail.com
GMAIL_APP_PASSWORD=your-16-char-app-password
```

## Step 5: Deploy Cloud Functions

```bash
cd functions
npm install
cd ..
firebase deploy --only functions
```

## How It Works

1. **Admin approves password reset** in the app
2. **Email is sent** to employee's Gmail with:
   - Password reset link
   - Professional email template
   - Clear instructions
3. **Push notification** is sent to employee's device simultaneously
4. **Employee receives both**:
   - Email in Gmail inbox
   - In-app notification on device

## Troubleshooting

### Email not being sent?

1. Check Firebase Cloud Functions logs:
   ```bash
   firebase functions:log
   ```

2. Verify Gmail credentials:
   - Go to [myaccount.google.com/apppasswords](https://myaccount.google.com/apppasswords)
   - Create a new app password if the old one is invalid
   - Update environment variables

3. Check if 2-Factor Authentication is enabled:
   - It's required for app passwords to work

### "Less secure app access" error?

- Modern Gmail requires App Passwords
- Don't use "Less secure app access" setting
- Follow Step 2 above to create an App Password

## Testing

1. Log in as **Admin** in the app
2. Go to **Password Approvals**
3. Create a password reset request (from employee account)
4. Approve it as admin
5. Check:
   - ✅ Email received in Gmail
   - ✅ Notification appears on device
   - ✅ Link works to reset password

## Email Template

The email includes:
- Greeting with employee name
- Clear approval message
- Prominent "Reset Password" button
- Plain text link as fallback
- 24-hour expiration notice
- Footer with app name

## Security Notes

- App passwords are different from your Gmail password
- They work only for this specific app
- You can revoke them anytime from App Passwords page
- Email addresses are only used for password reset, never stored elsewhere
- Links expire after 24 hours for security
