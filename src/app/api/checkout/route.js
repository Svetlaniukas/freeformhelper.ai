import { NextResponse } from 'next/server';
import Stripe from 'stripe';

export const dynamic = 'force-dynamic';

export async function POST(req) {
  try {
    const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);
    const baseUrl = process.env.NEXT_PUBLIC_BASE_URL || 'http://localhost:3000';
    
    const session = await stripe.checkout.sessions.create({
      payment_method_types: ['card'],
      line_items: [{
        price_data: {
          currency: 'usd',
          product_data: { name: 'FreeForm Helper Premium' },
          unit_amount: 499,
        },
        quantity: 1,
      }],
      mode: 'payment',
      success_url: `${baseUrl}?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: `${baseUrl}`,
    });
    return NextResponse.json({ url: session.url });
  } catch (error) {
    return NextResponse.json({ error: 'Stripe Error' }, { status: 500 });
  }
}
