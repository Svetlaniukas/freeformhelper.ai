import { NextResponse } from 'next/server';
import Stripe from 'stripe';
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

export async function GET(req) {
  const { searchParams } = new URL(req.url);
  const session_id = searchParams.get('session_id');
  if (!session_id) return NextResponse.json({ valid: false });
  try {
    const session = await stripe.checkout.sessions.retrieve(session_id);
    return NextResponse.json({ valid: session.payment_status === 'paid' });
  } catch (error) {
    return NextResponse.json({ valid: false });
  }
}
