# Email Verification Setup Guide

This guide will help you set up email verification for Wommi using Vercel serverless functions and Resend email service.

## Prerequisites

- Node.js installed (v18 or higher)
- Vercel CLI
- A Resend account (free tier)

## Step 1: Create Resend Account

1. Go to https://resend.com
2. Sign up for a free account (100 emails/day)
3. Verify your email address
4. Go to API Keys section
5. Create a new API key
6. **Copy and save this API key** - you'll need it later

## Step 2: Install Vercel CLI

```bash
npm install -g vercel
```

## Step 3: Deploy to Vercel

1. **Login to Vercel:**
   ```bash
   vercel login
   ```

2. **Deploy the project:**
   ```bash
   cd C:\work\wommi\wommi
   vercel
   ```

3. **Follow the prompts:**
   - Set up and deploy? **Yes**
   - Which scope? Choose your account
   - Link to existing project? **No**
   - What's your project's name? **wommi** (or any name you prefer)
   - In which directory is your code located? **./** (current directory)
   - Want to modify settings? **No**

4. **Note the deployment URL** - it will look like:
   ```
   https://wommi-xxxxxxx.vercel.app
   ```

## Step 4: Add Resend API Key to Vercel

1. Go to your Vercel dashboard: https://vercel.com/dashboard
2. Select your **wommi** project
3. Go to **Settings** → **Environment Variables**
4. Add a new environment variable:
   - **Key:** `RESEND_API_KEY`
   - **Value:** Your Resend API key from Step 1
   - **Environment:** Production, Preview, Development (select all)
5. Click **Save**

## Step 5: Redeploy with Environment Variables

```bash
vercel --prod
```

This redeploys your project with the API key.

## Step 6: Update Flutter App

1. Open `lib/widgets/profile_collection_dialog.dart`
2. Find this line near the top:
   ```dart
   const String API_URL = 'YOUR_VERCEL_URL/api/send-code';
   ```
3. Replace `YOUR_VERCEL_URL` with your actual Vercel URL:
   ```dart
   const String API_URL = 'https://wommi-xxxxxxx.vercel.app/api/send-code';
   ```

## Step 7: Rebuild and Deploy Flutter App

```bash
flutter build web --base-href "/wommi/"
```

Then copy the contents of `build/web` to your `docs` folder and push to GitHub.

## Testing the Email Verification

1. Run the app
2. When you reach the profile collection step:
   - Enter your name
   - Enter your email
   - Click "Send Code"
   - Check your email for a 6-digit verification code
   - Enter the code
   - Click "Complete"

## Troubleshooting

### Emails not sending

1. Check Vercel logs:
   ```bash
   vercel logs
   ```

2. Verify the RESEND_API_KEY is set correctly in Vercel dashboard

3. Check Resend dashboard for API usage and errors

### "Network error" in the app

1. Make sure the API_URL in `profile_collection_dialog.dart` matches your Vercel deployment URL
2. Check browser console for CORS errors
3. Verify the API is deployed and accessible by visiting:
   ```
   https://your-vercel-url.vercel.app/api/send-code
   ```

### Code verification failing

1. Make sure you're entering the 6-digit code correctly
2. Codes expire after 10 minutes - request a new one if needed
3. Check Vercel logs for verification errors

## Local Development

To test the API locally:

```bash
# Install dependencies
npm install

# Run Vercel dev server
vercel dev
```

The API will be available at `http://localhost:3000/api/send-code`

To test locally with the Flutter app, temporarily change API_URL to:
```dart
const String API_URL = 'http://localhost:3000/api/send-code';
```

**Don't forget to change it back to your production URL before deploying!**

## Security Notes

- Verification codes expire after 10 minutes
- Codes are stored in-memory (not persisted across serverless function instances)
- For production use, consider using Redis or a similar service for code storage
- Email uniqueness is still enforced in the local database
- The API validates email format before sending codes

## Cost

- Resend Free Tier: 100 emails/day (enough for testing and small-scale use)
- Vercel Free Tier: Sufficient for most small apps
- Both services offer paid tiers if you need more capacity
