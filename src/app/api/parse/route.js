import { NextResponse } from 'next/server';
import mammoth from 'mammoth';

export const dynamic = 'force-dynamic';

export async function POST(req) {
  try {
    const formData = await req.formData();
    const file = formData.get('file');

    if (!file) return NextResponse.json({ error: 'No file' }, { status: 400 });

    const buffer = Buffer.from(await file.arrayBuffer());
    let text = '';

    if (file.type === 'application/pdf') {
      try {
        const pdfParse = require('pdf-parse');
        const data = await pdfParse(buffer);
        text = data.text;
        
        if (!text || text.trim().length === 0) {
          throw new Error("Empty PDF");
        }
      } catch (e) {
        console.error(e);
        return NextResponse.json({ error: 'Could not read text. If this is a scanned PDF (image), please copy-paste the text manually.' }, { status: 400 });
      }
    } else if (file.name.endsWith('.docx')) {
      try {
        const result = await mammoth.extractRawText({ buffer });
        text = result.value;
      } catch (e) {
        return NextResponse.json({ error: 'DOCX corrupted.' }, { status: 400 });
      }
    } else {
      text = buffer.toString('utf-8');
    }

    return NextResponse.json({ text });
  } catch (error) {
    return NextResponse.json({ error: 'Server Error' }, { status: 500 });
  }
}
