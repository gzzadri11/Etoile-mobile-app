// Supabase Edge Function: Stripe Webhook Handler
// Handles Stripe webhook events for subscriptions and payments

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import Stripe from 'https://esm.sh/stripe@13.10.0?target=deno'

// Environment variables
const stripeSecretKey = Deno.env.get('STRIPE_SECRET_KEY')!
const stripeWebhookSecret = Deno.env.get('STRIPE_WEBHOOK_SECRET')!
const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

// Initialize clients
const stripe = new Stripe(stripeSecretKey, {
  apiVersion: '2023-10-16',
  httpClient: Stripe.createFetchHttpClient(),
})

const supabase = createClient(supabaseUrl, supabaseServiceKey)

// =============================================================================
// WEBHOOK HANDLERS
// =============================================================================

/**
 * Handle successful invoice payment
 */
async function handleInvoicePaid(invoice: Stripe.Invoice) {
  console.log('Processing invoice.paid:', invoice.id)

  const customerId = invoice.customer as string
  const subscriptionId = invoice.subscription as string

  if (!subscriptionId) {
    console.log('No subscription on invoice, skipping')
    return
  }

  // Get subscription details
  const subscription = await stripe.subscriptions.retrieve(subscriptionId)

  // Find user by Stripe customer ID
  const { data: subscriptionRecord, error: findError } = await supabase
    .from('subscriptions')
    .select('user_id')
    .eq('stripe_customer_id', customerId)
    .single()

  if (findError || !subscriptionRecord) {
    console.error('User not found for customer:', customerId)
    return
  }

  // Update subscription in database
  const { error: updateError } = await supabase
    .from('subscriptions')
    .update({
      status: 'active',
      current_period_start: new Date(subscription.current_period_start * 1000).toISOString(),
      current_period_end: new Date(subscription.current_period_end * 1000).toISOString(),
      updated_at: new Date().toISOString(),
    })
    .eq('stripe_subscription_id', subscriptionId)

  if (updateError) {
    console.error('Failed to update subscription:', updateError)
    return
  }

  // Update user premium status
  await supabase
    .from('users')
    .update({
      is_premium: true,
      premium_until: new Date(subscription.current_period_end * 1000).toISOString(),
      updated_at: new Date().toISOString(),
    })
    .eq('id', subscriptionRecord.user_id)

  console.log('Successfully processed invoice.paid for subscription:', subscriptionId)
}

/**
 * Handle failed invoice payment
 */
async function handleInvoicePaymentFailed(invoice: Stripe.Invoice) {
  console.log('Processing invoice.payment_failed:', invoice.id)

  const subscriptionId = invoice.subscription as string
  if (!subscriptionId) return

  // Update subscription status to past_due
  const { error } = await supabase
    .from('subscriptions')
    .update({
      status: 'past_due',
      updated_at: new Date().toISOString(),
    })
    .eq('stripe_subscription_id', subscriptionId)

  if (error) {
    console.error('Failed to update subscription status:', error)
  }

  console.log('Marked subscription as past_due:', subscriptionId)
}

/**
 * Handle subscription updates
 */
async function handleSubscriptionUpdated(subscription: Stripe.Subscription) {
  console.log('Processing customer.subscription.updated:', subscription.id)

  const status = mapStripeStatus(subscription.status)

  const { error } = await supabase
    .from('subscriptions')
    .update({
      status,
      current_period_start: new Date(subscription.current_period_start * 1000).toISOString(),
      current_period_end: new Date(subscription.current_period_end * 1000).toISOString(),
      canceled_at: subscription.canceled_at
        ? new Date(subscription.canceled_at * 1000).toISOString()
        : null,
      updated_at: new Date().toISOString(),
    })
    .eq('stripe_subscription_id', subscription.id)

  if (error) {
    console.error('Failed to update subscription:', error)
  }

  console.log('Updated subscription:', subscription.id, 'status:', status)
}

/**
 * Handle subscription deletion/cancellation
 */
async function handleSubscriptionDeleted(subscription: Stripe.Subscription) {
  console.log('Processing customer.subscription.deleted:', subscription.id)

  // Get subscription record
  const { data: subscriptionRecord, error: findError } = await supabase
    .from('subscriptions')
    .select('user_id')
    .eq('stripe_subscription_id', subscription.id)
    .single()

  if (findError || !subscriptionRecord) {
    console.error('Subscription not found:', subscription.id)
    return
  }

  // Update subscription status
  await supabase
    .from('subscriptions')
    .update({
      status: 'expired',
      canceled_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    })
    .eq('stripe_subscription_id', subscription.id)

  // Remove user premium status
  await supabase
    .from('users')
    .update({
      is_premium: false,
      premium_until: null,
      updated_at: new Date().toISOString(),
    })
    .eq('id', subscriptionRecord.user_id)

  console.log('Subscription deleted and user premium removed:', subscription.id)
}

/**
 * Handle successful checkout session (for one-time purchases)
 */
async function handleCheckoutSessionCompleted(session: Stripe.Checkout.Session) {
  console.log('Processing checkout.session.completed:', session.id)

  if (session.mode !== 'payment') {
    console.log('Not a one-time payment, skipping')
    return
  }

  const userId = session.metadata?.userId
  const productType = session.metadata?.productType
  const quantity = parseInt(session.metadata?.quantity || '1')

  if (!userId || !productType) {
    console.error('Missing metadata in checkout session')
    return
  }

  // Record the purchase
  const { error: purchaseError } = await supabase
    .from('purchases')
    .insert({
      user_id: userId,
      product_type: productType,
      quantity,
      unit_price_cents: session.amount_total ? Math.round(session.amount_total / quantity) : 0,
      total_price_cents: session.amount_total || 0,
      stripe_payment_intent_id: session.payment_intent as string,
      status: 'completed',
    })

  if (purchaseError) {
    console.error('Failed to record purchase:', purchaseError)
    return
  }

  // Update user credits
  if (productType === 'video_credit') {
    await supabase.rpc('increment_video_credits', {
      p_user_id: userId,
      p_amount: quantity,
    })
  } else if (productType === 'poster_credit') {
    await supabase.rpc('increment_poster_credits', {
      p_user_id: userId,
      p_amount: quantity,
    })
  }

  console.log('Purchase recorded:', productType, 'x', quantity, 'for user:', userId)
}

// =============================================================================
// HELPERS
// =============================================================================

function mapStripeStatus(stripeStatus: Stripe.Subscription.Status): string {
  switch (stripeStatus) {
    case 'active':
      return 'active'
    case 'canceled':
      return 'canceled'
    case 'past_due':
      return 'past_due'
    case 'trialing':
      return 'trialing'
    case 'unpaid':
    case 'incomplete':
    case 'incomplete_expired':
    case 'paused':
    default:
      return 'expired'
  }
}

// =============================================================================
// MAIN HANDLER
// =============================================================================

serve(async (req) => {
  // Only accept POST requests
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405 })
  }

  try {
    // Get the raw body and signature
    const body = await req.text()
    const signature = req.headers.get('stripe-signature')

    if (!signature) {
      return new Response('Missing stripe-signature header', { status: 400 })
    }

    // Verify webhook signature
    let event: Stripe.Event
    try {
      event = await stripe.webhooks.constructEventAsync(
        body,
        signature,
        stripeWebhookSecret
      )
    } catch (err) {
      console.error('Webhook signature verification failed:', err)
      return new Response('Invalid signature', { status: 400 })
    }

    console.log('Received webhook event:', event.type)

    // Handle the event
    switch (event.type) {
      case 'invoice.paid':
        await handleInvoicePaid(event.data.object as Stripe.Invoice)
        break

      case 'invoice.payment_failed':
        await handleInvoicePaymentFailed(event.data.object as Stripe.Invoice)
        break

      case 'customer.subscription.updated':
        await handleSubscriptionUpdated(event.data.object as Stripe.Subscription)
        break

      case 'customer.subscription.deleted':
        await handleSubscriptionDeleted(event.data.object as Stripe.Subscription)
        break

      case 'checkout.session.completed':
        await handleCheckoutSessionCompleted(event.data.object as Stripe.Checkout.Session)
        break

      default:
        console.log('Unhandled event type:', event.type)
    }

    return new Response(JSON.stringify({ received: true }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (error) {
    console.error('Webhook handler error:', error)
    return new Response(JSON.stringify({ error: 'Internal server error' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    })
  }
})
