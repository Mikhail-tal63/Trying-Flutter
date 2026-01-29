const nodemailer = require('nodemailer');

function createTransport() {
  const host = process.env.MAIL_HOST;
  const port = Number(process.env.MAIL_PORT || 587);
  const user = process.env.MAIL_USER;
  const pass = process.env.MAIL_PASS;

  if (!host || !user || !pass) return null;

  return nodemailer.createTransport({
    host,
    port,
    secure: port === 465,
    auth: { user, pass },
  });
}

async function sendMail({ to, subject, text }) {
  const transport = createTransport();
  if (!transport) return { skipped: true };

  const from = process.env.MAIL_FROM || process.env.MAIL_USER;
  await transport.sendMail({ from, to, subject, text });
  return { skipped: false };
}

module.exports = {
  sendMail,
};
