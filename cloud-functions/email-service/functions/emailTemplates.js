// Email templates for different types of wedding emails

const emailTemplates = {
  // Wedding invitation email
  invitation: (inviterName) => ({
    subject: 'Du wurdest eingeladen, bei einer Hochzeits-Checkliste mitzuarbeiten 💍',
    message: `Hi,

${inviterName} hat dich eingeladen, bei einer Hochzeits-Checkliste in der 4 Secrets Wedding App mitzuarbeiten! 👰🤵

So kannst du starten:

• Erstelle ein Konto oder melde dich in der App an
• Öffne das Seitenmenü
• Navigiere zum Hochzeitskit-Bildschirm
• Tippe auf die Titelleiste oben, um zur Seite Erhaltene Einladungen zu gelangen
• Nimm die Einladung an
• Kehre zur Hochzeitskit-Seite zurück, um mit der Zusammenarbeit zu beginnen

Viel Spaß beim Kommentieren und Abhaken von Checklistenpunkten!

Lade die App herunter und starte mit der Hochzeitsplanung:

Viel Spaß bei der Hochzeitsplanung! 💖

Liebe Grüße,
Dein 4 Secrets Wedding Team

📱 Android: https://play.google.com/store/apps/details?id=com.app.four_secrets_wedding_app
🍎 iOS: https://apps.apple.com/app/4-secrets-wedding/id[APP_ID]`
  }),

  // Declined invitation email
  declined: (declinerName) => ({
    subject: 'Einladung zur Hochzeits-Checkliste wurde abgelehnt',
    message: `Hi,

${declinerName} hat die Einladung zur Mitarbeit an der Hochzeits-Checkliste in der 4 Secrets Wedding App abgelehnt.

Du kannst jederzeit eine neue Einladung senden oder andere Personen zur Mitarbeit einladen.

Viel Erfolg bei der weiteren Hochzeitsplanung! 💍

Liebe Grüße,
Dein 4 Secrets Wedding Team`
  }),

  // Revoked access email
  revoked: (inviterName) => ({
    subject: 'Zugriff auf Hochzeits-Checkliste wurde entfernt',
    message: `Hallo,

${inviterName} hat deinen Zugriff auf die Hochzeits-Checkliste in der 4 Secrets Wedding App entfernt.

Du hast keinen Zugriff mehr auf die gemeinsame Hochzeitsplanung.

Falls du denkst, dass dies ein Fehler war, wende dich bitte an ${inviterName}.

Liebe Grüße,
Dein 4 Secrets Wedding Team`
  }),

  // Custom email template
  custom: (customSubject, customMessage) => ({
    subject: customSubject || 'Nachricht von 4 Secrets Wedding',
    message: customMessage || 'Hallo,\n\nDu hast eine Nachricht von der 4 Secrets Wedding App erhalten.\n\nLiebe Grüße,\nDein 4 Secrets Wedding Team'
  }),

  // Welcome email
  welcome: (userName) => ({
    subject: 'Willkommen bei 4 Secrets Wedding! 💍',
    message: `Hallo ${userName},

Willkommen bei 4 Secrets Wedding! 🎉

Wir freuen uns, dass du dich für unsere Hochzeitsplanungs-App entschieden hast. Mit 4 Secrets Wedding kannst du:

✨ Deine Hochzeit perfekt planen
📋 Checklisten erstellen und verwalten
👥 Familie und Freunde zur Mitarbeit einladen
💌 Wichtige Aufgaben koordinieren
🎯 Nichts vergessen mit unseren Erinnerungen

Lade die App herunter und beginne sofort:

📱 Android: https://play.google.com/store/apps/details?id=com.app.four_secrets_wedding_app
🍎 iOS: https://apps.apple.com/app/4-secrets-wedding/id[APP_ID]

Wir wünschen dir eine wundervolle Hochzeitsplanung! 💖

Liebe Grüße,
Dein 4 Secrets Wedding Team`
  }),

  // Password reset email
  passwordReset: (resetLink) => ({
    subject: 'Passwort zurücksetzen - 4 Secrets Wedding',
    message: `Hallo,

Du hast eine Anfrage zum Zurücksetzen deines Passworts für die 4 Secrets Wedding App gestellt.

Klicke auf den folgenden Link, um dein Passwort zurückzusetzen:
${resetLink}

Dieser Link ist 24 Stunden gültig.

Falls du diese Anfrage nicht gestellt hast, ignoriere diese E-Mail einfach.

Liebe Grüße,
Dein 4 Secrets Wedding Team`
  }),

  // Account verification email
  verification: (verificationLink) => ({
    subject: 'E-Mail-Adresse bestätigen - 4 Secrets Wedding',
    message: `Hallo,

Vielen Dank für deine Registrierung bei 4 Secrets Wedding! 💍

Bitte bestätige deine E-Mail-Adresse, indem du auf den folgenden Link klickst:
${verificationLink}

Nach der Bestätigung kannst du alle Funktionen der App nutzen.

Liebe Grüße,
Dein 4 Secrets Wedding Team`
  })
};

module.exports = emailTemplates;
