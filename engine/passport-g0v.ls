require! <[openid-client]>

issuer = new openid-client.Issuer do
  issuer: \http://localhost:9000
  authorization_endpoint: \http://localhost:9000/openid/auth
  token_endpoint: \http://localhost:9000/openid/token
  userinfo_endpoint: \http://localhost:9000/openid/me
  jwks_uri: \http://localhost:9000/openid/certs


    passport.use new passport-google-oauth2.Strategy(
      do
        clientID: config.google.clientID
        clientSecret: config.google.clientSecret
        callbackURL: "/u/auth/google/callback"
        passReqToCallback: true
        profileFields: ['id', 'displayName', 'link', 'emails']
      , (request, access-token, refresh-token, profile, done) ~>
        if !profile.emails =>
          done null, false, do
            message: "We can't get email address from your Google account. Please try signing up with email."
          return null
        get-user profile.emails.0.value, null, false, profile, true, done
    )


module.exports = do
