/**
 * ACNHS Shared Email Template
 * ─────────────────────────────────────────────────────────────────
 * Single source of truth for the outbound email HTML layout.
 * Edit THIS file to update the template everywhere:
 *   - email-template-preview.html  (live preview)
 *   - email-system.html            (compose & send)
 *
 * Placeholders replaced at send-time:
 *   {{SUBJECT}}         — email subject line
 *   {{EMAIL_TITLE}}     — large heading in the header band
 *   {{DATE}}            — formatted send date
 *   {{APPLICANT_NAME}}  — recipient first/last name
 *   {{BODY_CONTENT}}    — HTML body (paragraphs, buttons, etc.)
 *   {{STUDENT_INFO}}    — optional reference / control / doc-id block
 *   {{ACNHS_SEAL_BASE64}} — inline data-URI for the seal logo
 *   {{YEAR}}            — 4-digit year for the footer copyright
 * ─────────────────────────────────────────────────────────────────
 */
window.EMAIL_HTML_TEMPLATE = `<!doctype html>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>{{SUBJECT}}</title>
  <style>
    html,body{margin:0!important;padding:0!important;height:100%!important;width:100%!important}
    *{-ms-text-size-adjust:100%;-webkit-text-size-adjust:100%}
    table,td{mso-table-lspace:0pt!important;mso-table-rspace:0pt!important;border-collapse:collapse!important}
    img{-ms-interpolation-mode:bicubic;border:0;outline:none;text-decoration:none;display:block}
    a{color:inherit;text-decoration:none}
    @media(max-width:620px){.container{width:100%!important}.px{padding-left:20px!important;padding-right:20px!important}}
  </style>
</head>
<body style="margin:0;padding:0;background-color:#fbf8f2;">
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0"
         style="background-color:#fbf8f2;">
    <tr>
      <td align="center" style="padding:32px 10px 48px;">
        <table role="presentation" width="600" class="container" cellpadding="0" cellspacing="0"
          style="width:600px;max-width:600px;border-radius:18px;overflow:hidden;
            background-color:#fbf8f2;
            box-shadow:0 8px 48px rgba(4,17,31,0.18),0 2px 8px rgba(201,168,76,0.10);">

          <!-- HEADER -->
          <tr>
            <td style="background:linear-gradient(135deg,#04111f 0%,#071b30 60%,#0c2444 100%);
                       padding:28px 36px 24px;border-bottom:3px solid #c9a84c;">
              <table role="presentation" width="100%" cellpadding="0" cellspacing="0">
                <tr>
                  <td width="70" valign="middle" style="padding-right:18px;">
                    <img src="{{ACNHS_SEAL_BASE64}}" width="60" height="60" alt="ACNHS Seal"
                         style="border-radius:999px;background:rgba(201,168,76,0.12);
                                padding:6px;border:1.5px solid rgba(201,168,76,0.35);">
                  </td>
                  <td valign="middle">
                    <div style="font-family:Georgia,'Times New Roman',serif;font-size:17px;
                                color:#e2cc92;font-weight:700;letter-spacing:0.2px;line-height:1.25;">
                      Armenian College of Nursing
                    </div>
                    <div style="font-family:Georgia,'Times New Roman',serif;font-size:15px;
                                color:#d4b56a;font-weight:600;line-height:1.25;margin-top:2px;">
                      &amp; Health Sciences
                    </div>
                    <div style="font-family:Arial,sans-serif;font-size:11px;color:rgba(200,191,178,0.65);
                                font-weight:500;letter-spacing:2px;text-transform:uppercase;margin-top:7px;">
                      Yerevan, Republic of Armenia
                    </div>
                  </td>
                  <td valign="top" align="right" style="padding-left:14px;">{{STUDENT_INFO}}</td>
                </tr>
              </table>
              <div style="height:1px;background:linear-gradient(90deg,transparent 0%,rgba(201,168,76,0.15) 15%,#c9a84c 50%,rgba(201,168,76,0.15) 85%,transparent 100%);margin:20px 0 18px;"></div>
              <div style="font-family:Georgia,'Times New Roman',serif;font-size:24px;
                          color:#f0e3bc;font-weight:700;letter-spacing:-0.3px;line-height:1.25;">
                {{EMAIL_TITLE}}
              </div>
              <div style="font-family:Arial,sans-serif;font-size:11px;color:rgba(200,191,178,0.55);
                          font-weight:500;letter-spacing:1.5px;text-transform:uppercase;margin-top:8px;">
                {{DATE}}
              </div>
            </td>
          </tr>

          <!-- BODY -->
          <tr>
            <td class="px" style="background-color:transparent;padding:36px 36px 28px;">
              <div style="font-family:Georgia,'Times New Roman',serif;font-size:18px;
                          color:#04111f;font-weight:700;margin-bottom:16px;">
                Dear {{APPLICANT_NAME}},
              </div>
              <div style="font-family:Arial,Helvetica,sans-serif;font-size:15px;
                          line-height:1.75;color:#2c2a25;">
                {{BODY_CONTENT}}
              </div>
              <div style="height:1px;background:linear-gradient(90deg,transparent 0%,rgba(201,168,76,0.15) 15%,#c9a84c 50%,rgba(201,168,76,0.15) 85%,transparent 100%);margin:32px 0 28px;"></div>

              <!-- Signature -->
              <table role="presentation" cellpadding="0" cellspacing="0" style="border-collapse:collapse;width:100%;">
                <tr>
                  <td valign="middle">
                    <div style="margin-top:12px;">{{SIGNATURE}}</div>
                  </td>
                </tr>
              </table>
            </td>
          </tr>

          <!-- FOOTER DIVIDER -->
          <tr>
            <td style="padding:0;line-height:0;font-size:0;background:#04111f;">
              <div style="height:1px;background:linear-gradient(90deg,transparent 0%,rgba(201,168,76,0.15) 15%,#c9a84c 50%,rgba(201,168,76,0.15) 85%,transparent 100%);"></div>
            </td>
          </tr>

          <!-- FOOTER -->
          <tr>
            <td style="background:#04111f;padding:20px 36px;">
              <div style="font-family:Arial,sans-serif;font-size:11px;color:rgba(200,191,178,0.50);line-height:1.7;">
                &copy; {{YEAR}} Armenian College of Nursing &amp; Health Sciences. All rights reserved.
              </div>
              <div style="font-family:Arial,sans-serif;font-size:10px;color:rgba(200,191,178,0.30);margin-top:4px;line-height:1.6;">
                This message is intended solely for the named recipient. If you received this in error, please disregard and notify our office immediately.
              </div>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>`;
