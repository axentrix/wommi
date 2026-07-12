# Email Verification API

This API handles email verification codes for Wommi.

## Setup

1. **Get Resend API Key:**
   - Sign up at https://resend.com (free tier: 100 emails/day)
   - Create an API key
   - Add to Vercel environment variables as `RESEND_API_KEY`

2. **Deploy to Vercel:**
   ```bash
   npm install -g vercel
   vercel login
   vercel
   ```

3. **Set Environment Variable:**
   - Go to Vercel Dashboard → Project → Settings → Environment Variables
   - Add: `RESEND_API_KEY` = your_resend_api_key

4. **Update Frontend:**
   - Update `API_URL` in profile_collection_dialog.dart to your Vercel API URL
   - Example: `https://your-project.vercel.app/api/send-code`

## API Endpoints

### POST /api/send-code

**Send verification code:**
```json
{
  "email": "user@example.com",
  "action": "send"
}
```

**Verify code:**
```json
{
  "email": "user@example.com",
  "action": "verify",
  "code": "123456"
}
```

## Local Development

```bash
vercel dev
```

The API will be available at `http://localhost:3000/api/send-code`
