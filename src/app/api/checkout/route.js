import { NextResponse } from 'next/server';
import Stripe from 'stripe';

export const dynamic = 'force-dynamic';

const PLANS = {
  pro: {
    name: 'FreeFormHelper Pro',
    description: '20,000 words/month + PDF/DOCX upload',
    amount: 999, // €9.99
    currency: 'eur',
  },
  premium: {
    name: 'FreeFormHelper Premium',
    description: 'Unlimited words + Chrome Extension + Priority',
    amount: 2499, // €24.99
    currency: 'eur',
  },
};

export async function POST(req) {
  try {
    const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);
    const baseUrl = process.env.NEXT_PUBLIC_BASE_URL || 'http://localhost:3000';
    const { plan = 'pro' } = await req.json().catch(() => ({}));

    const planData = PLANS[plan] || PLANS.pro;

    const session = await stripe.checkout.sessions.create({
      payment_method_types: ['card'],
      line_items: [{
        price_data: {
          currency: planData.currency,
          product_data: {
            name: planData.name,
            description: planData.description,
          },
          unit_amount: planData.amount,
          recurring: { interval: 'month' },
        },
        quantity: 1,
      }],
      mode: 'subscription',
      success_url: `${baseUrl}?session_id={CHECKOUT_SESSION_ID}&plan=${plan}`,
      cancel_url: `${baseUrl}?cancelled=true`,
      metadata: { plan },
    });

    return NextResponse.json({ url: session.url });
  } catch (error) {
    console.error('Stripe error:', error.message);
    return NextResponse.json({ error: 'Payment error' }, { status: 500 });
  }
}
