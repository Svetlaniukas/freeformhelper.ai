import { NextResponse } from 'next/server';
import Stripe from 'stripe';

export const dynamic = 'force-dynamic';

export async function GET(req) {
  const { searchParams } = new URL(req.url);
  const session_id = searchParams.get('session_id');
  if (!session_id) return NextResponse.json({ valid: false });
  try {
    const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);
    const session = await stripe.checkout.sessions.retrieve(session_id);
    return NextResponse.json({ valid: session.payment_status === 'paid' });
  } catch (error) {
    return NextResponse.json({ valid: false });
  }
}
