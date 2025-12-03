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
      // ИСПРАВЛЕНИЕ: Динамический импорт, чтобы сборка не падала
      const pdfParse = require('pdf-parse');
      const data = await pdfParse(buffer);
      text = data.text;
    } else if (file.name.endsWith('.docx')) {
      const result = await mammoth.extractRawText({ buffer });
      text = result.value;
    } else {
      text = buffer.toString('utf-8');
    }
    return NextResponse.json({ text });
  } catch (error) {
    return NextResponse.json({ error: 'Parsing failed' }, { status: 500 });
  }
}
