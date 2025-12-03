import { NextResponse } from 'next/server';
import mammoth from 'mammoth';

export const dynamic = 'force-dynamic';

export async function POST(req) {
  try {
    const formData = await req.formData();
    const file = formData.get('file');

    if (!file) return NextResponse.json({ error: 'No file uploaded' }, { status: 400 });

    const buffer = Buffer.from(await file.arrayBuffer());
    let text = '';

    console.log(`Processing file: ${file.name} (${file.type})`);

    if (file.type === 'application/pdf') {
      try {
        // Используем require внутри try/catch для безопасности
        const pdfParse = require('pdf-parse');
        const data = await pdfParse(buffer);
        text = data.text;
      } catch (pdfError) {
        console.error("PDF Parse Error:", pdfError);
        return NextResponse.json({ error: 'Failed to read PDF. Try converting to DOCX or TXT.' }, { status: 500 });
      }
    } else if (file.name.endsWith('.docx')) {
      try {
        const result = await mammoth.extractRawText({ buffer });
        text = result.value;
      } catch (docxError) {
        return NextResponse.json({ error: 'Failed to read DOCX.' }, { status: 500 });
      }
    } else {
      // Пробуем прочитать как простой текст
      text = buffer.toString('utf-8');
    }

    // Если текст пустой или мусор
    if (!text || text.trim().length < 5) {
      return NextResponse.json({ error: 'File is empty or unreadable.' }, { status: 400 });
    }

    return NextResponse.json({ text });
  } catch (error) {
    console.error("General Upload Error:", error);
    return NextResponse.json({ error: 'Upload failed on server.' }, { status: 500 });
  }
}
