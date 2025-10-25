# Self Protocol Integration Setup

This guide explains how to set up the Self QR SDK integration for operator identity verification.

## Environment Variables

Add the following environment variables to your `.env.local` file (optional - defaults are provided):

```
NEXT_PUBLIC_SELF_APP_NAME=Arx Protocol
NEXT_PUBLIC_SELF_SCOPE=arx-protocol
NEXT_PUBLIC_SELF_ENDPOINT=https://playground.self.xyz/api/verify
```

### Configuration Details

- **NEXT_PUBLIC_SELF_APP_NAME**: Display name of your app in the Self verification flow (default: "Arx Protocol")
- **NEXT_PUBLIC_SELF_SCOPE**: Unique scope identifier for your app (default: "arx-protocol")
- **NEXT_PUBLIC_SELF_ENDPOINT**: Self Protocol verification endpoint - **must be a full URL** (default: "https://playground.self.xyz/api/verify")

**Important**: The endpoint must be a complete URL with protocol (https://), not a relative path.

For production, update the endpoint to the mainnet URL provided by Self Protocol.

## Installation

The dependencies have been added to `package.json`:

```bash
npm install
# or
yarn install
# or
pnpm install
```

## How It Works

### Frontend Flow

1. Operator clicks "Register as Operator" button on the stakes page
2. Self verification modal opens with a QR code
3. Operator scans QR code with Self app on mobile
4. User provides identity proof (age, nationality, gender)
5. Upon successful verification, the registration modal opens
6. Operator can now proceed with staking

### Backend Verification

The verification endpoint at `/api/self-verify` handles proof verification:

- Receives attestation data from the frontend
- Verifies the zero-knowledge proof using `SelfBackendVerifier`
- Returns verification status

## Components

### `components/self-verification.tsx`

React component that displays:
- QR code for scanning with Self app
- Verification status indicator
- Success/error states
- Automatic callback on successful verification

### `app/api/self-verify/route.ts`

Next.js API route that:
- Accepts POST requests with proof data
- Verifies proofs using Self SDK
- Returns verification results

## Configuration Matching

**Important**: Frontend and backend configurations must match exactly:

```javascript
// Frontend (in self-verification.tsx)
disclosures: {
  minimumAge: 18,
  nationality: true,
  gender: true,
}

// Backend (in api/self-verify/route.ts)
new DefaultConfigStore({
  minimumAge: 18,
  excludedCountries: ["IRN", "PRK", "RUS", "SYR"],
  ofac: true,
})
```

## Testing

For local development:

1. Set `endpointType: "staging_https"` in the component (already configured)
2. Use the staging endpoint in environment variables
3. The Self app will use staging credentials for testing

## Deployment Notes

- The verification endpoint must be publicly accessible (not localhost)
- For local development, use ngrok or similar tunneling service
- Update environment variables for production endpoints
- Ensure CORS is properly configured if needed

## Troubleshooting

### QR Code Not Displaying
- Check that `@selfxyz/qrcode` is properly installed
- Verify environment variables are set
- Check browser console for errors

### Verification Failing
- Ensure frontend and backend configurations match
- Verify the Self app is installed on the mobile device
- Check that the endpoint is accessible
- Review backend logs for detailed error messages

### Module Not Found Errors
- Run `npm install` to ensure all dependencies are installed
- Clear `.next` directory and rebuild
- Check that `@selfxyz/core` and `@selfxyz/qrcode` are in package.json
