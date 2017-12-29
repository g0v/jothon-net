module.exports = do
  config: \default
  port: \9000 # backend port
  limit: '20mb'
  watch: true
  superuser: \<your-username>

  paypal:
    sandbox:
      user: \<your-key-here>
      pass: \<your-key-here>
    production:
      user: \<your-key-here>
      pass: \<your-key-here>

  facebook:
    clientSecret: \<your-key-here>

  google:
    clientSecret: \<your-key-here>

  cookie:
    domain: null

  session:
    secret: \<your-random-string-here>

  token-secret: \<your-random-string-here>

  mail: do
    host: \<your-mail-smtp-server>
    port: 465
    secure: true
    maxConnections: 5
    maxMessages: 10
    auth: {user: '', pass: ''}

  mailgun: do
    auth:
      domain: \<your-mailgun-domain>
      api_key: \<your-key-here>

  usedb: false
  io-pg: do
    uri: "<your-postgresql-url>"
