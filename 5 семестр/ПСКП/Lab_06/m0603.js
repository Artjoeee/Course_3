const nodemailer = require('nodemailer');

const FIXED_EMAIL = 'artzham04022005@gmail.com';

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: 'artzham04022005@gmail.com',
    pass: 'xgrbynzzaivkzhlj'
  }
});

function send(message) {
  const mailOptions = {
    from: 'artom111by@gmail.com',
    to: FIXED_EMAIL,
    subject: 'm0603',
    html: `<p>${message}</p>`
  };

  transporter.sendMail(mailOptions, (err, info) => {
    if (err) {
        console.error('Ошибка отправки:', err);
    }
    else {
        console.log('Письмо отправлено:', info.response);
    }
  });
}

module.exports = { send };
