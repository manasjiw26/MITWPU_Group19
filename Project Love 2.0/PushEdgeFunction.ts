/*
  Supabase Edge Function for Apple Push Notifications (APNs)
  
  Pre-requisites:
  1. Install Supabase CLI: `brew install supabase/tap/supabase`
  2. Setup locally: `supabase init`
  3. Create function: `supabase functions new push-notification`
  4. Copy this code into `supabase/functions/push-notification/index.ts`
  5. Deploy: `supabase functions deploy push-notification`
*/

import { serve } from "https://deno.land/std@0.177.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
// Note: Since you are calling Apple's HTTP/2 APIs, you typically need to generate a JWT for auth. 
// A library like 'https://deno.land/x/djwt/mod.ts' is commonly used here to sign the token.
import { create } from "https://deno.land/x/djwt@v2.8/mod.ts"

// ==========================================
// CONFIGURATION: Replace these in your Edge Function Secrets
// supabase secrets set APNS_KEY_ID=your_key_id
// supabase secrets set APNS_TEAM_ID=your_team_id
// supabase secrets set APNS_PRIVATE_KEY="your_p8_file_contents"
// supabase secrets set APP_BUNDLE_ID="com.yourcompany.projectlove"
// ==========================================

serve(async (req: Request) => {
  try {
    // 1. Parse the Webhook Payload
    const payload = await req.json()
    const record = payload.record // The inserted row from 'notifications' table

    // 2. Filter: Only send push for targeted notification types
    const targetedTypes = ["love_note_sent", "mood_updated", "nudge_sent", "memory_added"]
    if (!targetedTypes.includes(record.type)) {
      console.log(`Notification type '${record.type}' ignored for Push.`)
      return new Response(JSON.stringify({ success: true, ignored: true }), { status: 200 })
    }

    // 3. Fetch the Receiver's Device Token
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? ''
    )
    
    const { data: userData, error: userError } = await supabaseClient
      .from('users')
      .select('apns_token')
      .eq('id', record.receiver_user_id)
      .single()

    if (userError || !userData?.apns_token) {
        console.error("User missing APNs token")
        return new Response(JSON.stringify({ error: "Missing APNs token" }), { status: 400 })
    }

    const deviceToken = userData.apns_token

    // 4. Generate APNs JWT Auth Token
    const privateKeyStr = Deno.env.get('APNS_PRIVATE_KEY')!
    const keyId = Deno.env.get('APNS_KEY_ID')!
    const teamId = Deno.env.get('APNS_TEAM_ID')!
    
    // Import the Private Key for signing
    const keyBytes = Uint8Array.from(atob(privateKeyStr.replace(/-----\w+ PRIVATE KEY-----|\s/g, "")), c => c.charCodeAt(0));
    const privateKey = await crypto.subtle.importKey(
      "pkcs8",
      keyBytes,
      { name: "ECDSA", namedCurve: "P-256" },
      false,
      ["sign"]
    )

    const jwt = await create(
        { alg: "ES256", kid: keyId },
        { iss: teamId, iat: Math.floor(Date.now() / 1000) },
        privateKey
    )

    // 5. Send POST Request to Apple Push Servers
    const bundleId = Deno.env.get('APP_BUNDLE_ID')!
    const apnsHost = "api.push.apple.com" // or api.sandbox.push.apple.com for Dev

    let pushTitle = "New Notification"
    if (record.type === "love_note_sent") pushTitle = "You received a Love Note! 💌"
    if (record.type === "mood_updated") pushTitle = "Your partner updated their mood 🎭"
    if (record.type === "nudge_sent") pushTitle = "You received a Nudge! 👀"
    if (record.type === "memory_added") pushTitle = "A new memory was added to the jar! 🫙"

    const apnsPayload = {
      aps: {
        alert: {
          title: pushTitle,
          body: record.message || "Open the app to see more."
        },
        sound: "default"
      }
    }

    const apnsResponse = await fetch(`https://${apnsHost}/3/device/${deviceToken}`, {
      method: "POST",
      headers: {
        "authorization": `bearer ${jwt}`,
        "apns-topic": bundleId,
        "apns-push-type": "alert"
      },
      body: JSON.stringify(apnsPayload)
    })

    if (!apnsResponse.ok) {
        const errText = await apnsResponse.text()
        throw new Error(`APNs Error: ${apnsResponse.status} ${errText}`)
    }

    return new Response(JSON.stringify({ success: true, message: "Push Sent!" }), { status: 200 })
  } catch (error) {
    console.error(error)
    return new Response(JSON.stringify({ error: error.message }), { status: 500 })
  }
})
