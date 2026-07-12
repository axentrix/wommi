# Email Verification Setup Instructions

## Quick Setup (5 minutes):

1. **Create Resend Account:**
   - Go to https://resend.com
   - Sign up (free: 100 emails/day)
   - Create API key

2. **Deploy API to Vercel:**
   ```bash
   cd wommi
   vercel login
   vercel
   ```
   - Follow prompts
   - Note the deployment URL

3. **Add API Key:**
   - Vercel Dashboard → Your Project → Settings → Environment Variables
   - Add: RESEND_API_KEY = your_api_key_here
   - Redeploy: `vercel --prod`

4. **Update App:**
   - I'll update the code to use your Vercel URL
   - Tell me your Vercel project URL when ready

## What you'll need:
- Resend API key
- Vercel deployment URL

Let me know when you have these and I'll finalize the integration!
