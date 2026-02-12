const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const config = require('../config/config');
const Business = require('../models/Business');

// Initialize Stripe (only if secret key is configured)
let stripe = null;
if (config.stripe.secretKey) {
  stripe = require('stripe')(config.stripe.secretKey);
  console.log('Stripe initialized successfully');
} else {
  console.warn('STRIPE_SECRET_KEY not set - payment endpoints will run in free/test mode');
}

// ==================== Event Posting Payment ====================

// POST /api/payment/create-event-payment-intent
// Creates a payment intent for posting a business event.
// In free mode (no Stripe key), returns a free pass.
router.post('/create-event-payment-intent', auth, async (req, res) => {
  try {
    const business = await Business.findOne({ userId: req.user.userId });
    if (!business) {
      return res.status(404).json({ success: false, message: 'Business not found' });
    }

    // Free mode: no Stripe key configured, allow posting for free
    if (!stripe) {
      return res.json({
        success: true,
        data: {
          clientSecret: null,
          paymentIntentId: null,
          freeMode: true,
          message: 'Event posting is currently free!',
        },
      });
    }

    // Check if business has an active subscription that covers event posting
    const sub = business.subscriptionStatus;
    if (sub && sub.status === 'active') {
      if (sub.expiryDate && sub.expiryDate > new Date()) {
        return res.json({
          success: true,
          data: {
            clientSecret: null,
            paymentIntentId: null,
            coveredBySubscription: true,
            message: 'Event covered by your subscription.',
          },
        });
      } else {
        // Auto-expire the subscription
        business.subscriptionStatus.status = 'expired';
        await business.save();
      }
    }

    // Create a Stripe payment intent for per-event posting
    // Price is enforced server-side to prevent tampering
    const EVENT_POSTING_PRICE = 999; // $9.99

    const paymentIntent = await stripe.paymentIntents.create({
      amount: EVENT_POSTING_PRICE,
      currency: 'usd',
      metadata: {
        businessId: business.businessId.toString(),
        userId: req.user.userId.toString(),
        type: 'event_posting',
      },
    });

    res.json({
      success: true,
      data: {
        clientSecret: paymentIntent.client_secret,
        paymentIntentId: paymentIntent.id,
      },
    });
  } catch (error) {
    console.error('Create event payment intent error:', error);
    res.status(500).json({ success: false, message: 'Failed to create payment intent' });
  }
});

// ==================== Subscription Management ====================

// POST /api/payment/stripe/create-payment-intent
// Generic payment intent creation for subscriptions
router.post('/stripe/create-payment-intent', auth, async (req, res) => {
  try {
    const { planId } = req.body;

    // Determine price server-side based on plan
    const planPrices = { pro: 2900, enterprise: 9900 };
    if (!planPrices[planId]) {
      return res.status(400).json({ success: false, message: 'Invalid plan ID. Must be pro or enterprise' });
    }
    const amount = planPrices[planId];

    // Free mode
    if (!stripe) {
      return res.json({
        success: true,
        data: {
          clientSecret: 'free_mode_' + Date.now(),
          paymentIntentId: 'pi_free_' + Date.now(),
          freeMode: true,
        },
      });
    }

    const paymentIntent = await stripe.paymentIntents.create({
      amount,
      currency: 'usd',
      metadata: {
        userId: req.user.userId.toString(),
        type: 'subscription',
      },
    });

    res.json({
      success: true,
      data: {
        clientSecret: paymentIntent.client_secret,
        paymentIntentId: paymentIntent.id,
      },
    });
  } catch (error) {
    console.error('Create payment intent error:', error);
    res.status(500).json({ success: false, message: 'Failed to create payment intent' });
  }
});

// POST /api/payment/verify
// Verify a payment was successful
router.post('/verify', auth, async (req, res) => {
  try {
    const { paymentIntentId } = req.body;

    if (!paymentIntentId) {
      return res.status(400).json({ success: false, message: 'Payment intent ID required' });
    }

    // Free mode - always succeeds
    if (!stripe || paymentIntentId.startsWith('pi_free_') || paymentIntentId.startsWith('free_mode_')) {
      return res.json({ success: true, message: 'Payment verified (free mode)', data: { status: 'succeeded' } });
    }

    // Verify with Stripe
    const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);

    if (paymentIntent.status === 'succeeded') {
      return res.json({
        success: true,
        message: 'Payment verified',
        data: { status: 'succeeded' },
      });
    }

    res.status(400).json({
      success: false,
      message: `Payment not completed. Status: ${paymentIntent.status}`,
      data: { status: paymentIntent.status },
    });
  } catch (error) {
    console.error('Verify payment error:', error);
    res.status(500).json({ success: false, message: 'Failed to verify payment' });
  }
});

// POST /api/payment/upgrade-to-premium
// Upgrade business to a subscription plan
router.post('/upgrade-to-premium', auth, async (req, res) => {
  try {
    const { planId, paymentIntentId } = req.body;

    const business = await Business.findOne({ userId: req.user.userId });
    if (!business) {
      return res.status(404).json({ success: false, message: 'Business not found' });
    }

    // Determine plan details
    const plans = {
      basic: { name: 'Basic', price: 0, durationDays: 365 },
      pro: { name: 'Pro', price: 2900, durationDays: 30 },
      enterprise: { name: 'Enterprise', price: 9900, durationDays: 30 },
    };

    const plan = plans[planId];
    if (!plan) {
      return res.status(400).json({ success: false, message: 'Invalid plan ID. Must be basic, pro, or enterprise' });
    }

    // If Stripe is configured and plan is paid, verify the payment
    if (stripe && plan.price > 0) {
      if (!paymentIntentId) {
        return res.status(400).json({ success: false, message: 'Payment required for this plan' });
      }

      // Idempotency: check if this paymentIntentId was already used
      if (business.subscriptionStatus && business.subscriptionStatus.paymentIntentId === paymentIntentId) {
        return res.json({
          success: true,
          message: `Already upgraded to ${business.subscriptionStatus.planName} plan`,
          data: { subscriptionStatus: business.subscriptionStatus },
        });
      }

      const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);
      if (paymentIntent.status !== 'succeeded') {
        return res.status(400).json({ success: false, message: 'Payment not completed' });
      }
      // Verify the payment amount exactly matches the plan price
      if (paymentIntent.amount !== plan.price) {
        return res.status(400).json({ success: false, message: 'Payment amount does not match plan price' });
      }
    }

    // Atomic update to prevent race condition on concurrent upgrade requests
    const now = new Date();
    const expiryDate = new Date(now.getTime() + plan.durationDays * 24 * 60 * 60 * 1000);

    const newSubStatus = {
      planId: planId || 'basic',
      planName: plan.name,
      status: 'active',
      startDate: now,
      expiryDate: expiryDate,
      paymentIntentId: paymentIntentId || null,
    };

    // Use atomic update: only update if paymentIntentId hasn't been set to this value
    const updateQuery = paymentIntentId
      ? { userId: req.user.userId, 'subscriptionStatus.paymentIntentId': { $ne: paymentIntentId } }
      : { userId: req.user.userId };

    const updated = await Business.findOneAndUpdate(
      updateQuery,
      { $set: { subscriptionStatus: newSubStatus } },
      { new: true }
    );

    if (!updated) {
      // Already processed this paymentIntentId
      return res.json({
        success: true,
        message: `Already upgraded to ${plan.name} plan`,
        data: { subscriptionStatus: business.subscriptionStatus },
      });
    }

    res.json({
      success: true,
      message: `Upgraded to ${plan.name} plan`,
      data: {
        subscriptionStatus: updated.subscriptionStatus,
      },
    });
  } catch (error) {
    console.error('Upgrade to premium error:', error);
    res.status(500).json({ success: false, message: 'Failed to upgrade' });
  }
});

// POST /api/payment/cancel-subscription
// Cancel the active subscription
router.post('/cancel-subscription', auth, async (req, res) => {
  try {
    const business = await Business.findOne({ userId: req.user.userId });
    if (!business) {
      return res.status(404).json({ success: false, message: 'Business not found' });
    }

    if (business.subscriptionStatus) {
      business.subscriptionStatus.status = 'cancelled';
      await business.save();
    }

    res.json({
      success: true,
      message: 'Subscription cancelled',
    });
  } catch (error) {
    console.error('Cancel subscription error:', error);
    res.status(500).json({ success: false, message: 'Failed to cancel subscription' });
  }
});

module.exports = router;
