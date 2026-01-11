// @ts-ignore Remote import provided by Deno runtime
import { assertEquals } from "https://deno.land/std@0.203.0/testing/asserts.ts"
import { extractEmailBody } from "./index.ts"

declare const Deno: {
  test: (name: string, fn: () => Promise<void> | void) => void
}

Deno.test('extracts plain text directly', async () => {
  const body = await extractEmailBody({ text: 'Hello there!' })
  assertEquals(body, 'Hello there!')
})

Deno.test('strips html to text', async () => {
  const body = await extractEmailBody({ html: '<p>Hi <strong>team</strong></p>' })
  assertEquals(body, 'Hi team')
})

Deno.test('parses base64 MIME payload', async () => {
  const mime = [
    'Content-Type: multipart/alternative; boundary="abc123"',
    '',
    '--abc123',
    'Content-Type: text/plain; charset="UTF-8"',
    'Content-Transfer-Encoding: base64',
    '',
    btoa('Thanks for the update!'),
    '--abc123--',
    ''
  ].join('\r\n')

  const body = await extractEmailBody({ raw: { data: btoa(mime), encoding: 'base64' } })
  assertEquals(body, 'Thanks for the update!')
})
