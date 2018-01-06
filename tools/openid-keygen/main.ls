require! <[fs path]>
require! <[oidc-provider]>

keystore = oidc-provider.createKeyStore!

Promise.all([
  keystore.generate('RSA', 2048),
  keystore.generate('EC', 'P-256'),
  keystore.generate('EC', 'P-384'),
  keystore.generate('EC', 'P-521')
]).then -> fs.write-file-sync \keystore.json, JSON.stringify(keystore.toJSON(true), null, 2)
