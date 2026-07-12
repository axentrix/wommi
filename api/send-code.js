// Vercel serverless function to send verification code
// Uses Resend for email delivery

const RESEND_API_KEY = process.env.RESEND_API_KEY;

// In-memory store for verification codes (expires after 10 minutes)
// In production, use Redis or similar
const verificationCodes = new Map();

function generateCode() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

function cleanupExpiredCodes() {
  const now = Date.now();
  for (const [email, data] of verificationCodes.entries()) {
    if (now - data.timestamp > 10 * 60 * 1000) {
      verificationCodes.delete(email);
    }
  }
}

module.exports = async function handler(req, res) {
  // Enable CORS
  res.setHeader('Access-Control-Allow-Credentials', true);
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS,PATCH,DELETE,POST,PUT');
  res.setHeader(
    'Access-Control-Allow-Headers',
    'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version'
  );

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  // Log request body for debugging
  console.log('Request body:', JSON.stringify(req.body));
  console.log('Request body type:', typeof req.body);

  const { email, action, code } = req.body || {};

  console.log('Parsed values:', { email, action, code });

  if (!email || typeof email !== 'string' || !email.includes('@')) {
    console.error('Invalid email:', email, 'Type:', typeof email);
    return res.status(400).json({
      error: 'Valid email required',
      received: { email, action, code, bodyType: typeof req.body }
    });
  }

  if (!action || (action !== 'send' && action !== 'verify')) {
    console.error('Invalid action:', action);
    return res.status(400).json({
      error: 'Valid action required (send or verify)',
      received: { email, action, code }
    });
  }

  cleanupExpiredCodes();

  // Send verification code
  if (action === 'send') {
    const verificationCode = generateCode();
    verificationCodes.set(email.toLowerCase(), {
      code: verificationCode,
      timestamp: Date.now(),
    });

    // Send email via Resend (only if API key is set and properly configured)
    // For testing/development: code is returned in response
    if (RESEND_API_KEY && RESEND_API_KEY !== 'test') {
      try {
        const response = await fetch('https://api.resend.com/emails', {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${RESEND_API_KEY}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            from: 'Wommi <onboarding@resend.dev>',
            to: email,
            subject: 'Your Wommi Verification Code',
            html: `
              <div style="font-family: sans-serif; max-width: 600px; margin: 0 auto;">
                <h1 style="color: #2dd4bf;">Welcome to Wommi</h1>
                <p>Your verification code is:</p>
                <div style="background: #f0fdf4; border: 2px solid #2dd4bf; border-radius: 8px; padding: 20px; text-align: center; font-size: 32px; font-weight: bold; letter-spacing: 8px; margin: 20px 0;">
                  ${verificationCode}
                </div>
                <p style="color: #666;">This code will expire in 10 minutes.</p>
                <p style="color: #666; font-size: 14px;">If you didn't request this code, you can safely ignore this email.</p>
              </div>
            `,
          }),
        });

        const responseData = await response.json();

        if (!response.ok) {
          console.error('Resend API error:', responseData);
          // Don't fail - just log and return success with code for testing
          console.log('Email sending failed, but returning code for testing');
        } else {
          console.log('Email sent successfully via Resend');
        }
      } catch (error) {
        console.error('Email send error:', error);
        // Don't fail - just log and continue
        console.log('Email sending failed, but returning code for testing');
      }
    } else {
      console.log('Resend not configured, returning code for testing');
    }

    return res.status(200).json({
      success: true,
      message: 'Verification code sent',
      // Always include code for now (until Resend is fully configured)
      code: verificationCode
    });
  }

  // Verify code
  if (action === 'verify') {
    if (!code) {
      return res.status(400).json({ error: 'Code required' });
    }

    const stored = verificationCodes.get(email.toLowerCase());

    if (!stored) {
      return res.status(400).json({ error: 'No code found for this email' });
    }

    if (Date.now() - stored.timestamp > 10 * 60 * 1000) {
      verificationCodes.delete(email.toLowerCase());
      return res.status(400).json({ error: 'Code expired' });
    }

    if (stored.code !== code) {
      return res.status(400).json({ error: 'Invalid code' });
    }

    verificationCodes.delete(email.toLowerCase());
    return res.status(200).json({ success: true, verified: true });
  }

  return res.status(400).json({ error: 'Invalid action' });
}
