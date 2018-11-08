Content-Type: multipart/mixed; boundary="===============5372603935175805995=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 5/5] unit: Update tests to new certificate API
Date: Fri, 09 Nov 2018 00:30:17 +0100
Message-ID: <CAOq732JWYYpDp8SAbrdSQN42h_MBND50XhQ0zk5890_zXkJVOw@mail.gmail.com>
In-Reply-To: <alpine.OSX.2.21.1811081520140.6689@dbdavenp-mobl.amr.corp.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5372603935175805995==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Fri, 9 Nov 2018 at 00:27, Mat Martineau
<mathew.j.martineau@linux.intel.com> wrote:
> On Thu, 8 Nov 2018, Andrew Zaborowski wrote:
> > ---
> > unit/test-key.c | 89 ++++++++++++++++++++-----------------------------
> > unit/test-pem.c | 57 ++++++++++++++++++-------------
> > unit/test-tls.c | 24 ++++++-------
> > 3 files changed, 83 insertions(+), 87 deletions(-)
> >
> > diff --git a/unit/test-key.c b/unit/test-key.c
> > index afe4103..5f65793 100644
> > --- a/unit/test-key.c
> > +++ b/unit/test-key.c
> > @@ -394,23 +394,20 @@ static void test_trusted_keyring(const void *data)
> > {
> >       struct l_keyring *ring;
> >       struct l_keyring *trust;
> > -     uint8_t *cacert;
> > -     size_t cacertlen;
> > -     uint8_t *cert;
> > -     size_t certlen;
> > +     struct l_cert *cacert;
> > +     struct l_cert *cert;
> >       struct l_key *cakey;
> >       struct l_key *key;
> >       bool success;
> >
> > -     cacert =3D l_pem_load_certificate(CERTDIR "cert-ca.pem", &cacertl=
en);
> > +     cacert =3D l_pem_load_certificate(CERTDIR "cert-ca.pem");
> >       assert(cacert);
> > -     cert =3D l_pem_load_certificate(CERTDIR "cert-server.pem",
> > -                                     &certlen);
> > +     cert =3D l_pem_load_certificate(CERTDIR "cert-server.pem");
> >       assert(cert);
> >
> > -     cakey =3D l_key_new(L_KEY_RSA, cacert, cacertlen);
> > +     cakey =3D l_cert_get_pubkey(cacert);
> >       assert(cakey);
> > -     key =3D l_key_new(L_KEY_RSA, cert, certlen);
> > +     key =3D l_cert_get_pubkey(cert);
> >       assert(key);
> >
> >       trust =3D l_keyring_new();
> > @@ -431,39 +428,34 @@ static void test_trusted_keyring(const void *data)
> >       l_keyring_free(ring);
> >       l_key_free(cakey);
> >       l_key_free(key);
> > -     l_free(cacert);
> > -     l_free(cert);
> > +     l_cert_free(cacert);
> > +     l_cert_free(cert);
> > }
> >
> > static void test_trust_chain(const void *data)
> > {
> >       struct l_keyring *ring;
> >       struct l_keyring *trust;
> > -     uint8_t *cacert;
> > -     size_t cacertlen;
> > -     uint8_t *intcert;
> > -     size_t intcertlen;
> > -     uint8_t *cert;
> > -     size_t certlen;
> > +     struct l_cert *cacert;
> > +     struct l_cert *intcert;
> > +     struct l_cert *cert;
> >       struct l_key *cakey;
> >       struct l_key *intkey;
> >       struct l_key *key;
> >       bool success;
> >
> > -     cacert =3D l_pem_load_certificate(CERTDIR "cert-ca.pem", &cacertl=
en);
> > +     cacert =3D l_pem_load_certificate(CERTDIR "cert-ca.pem");
> >       assert(cacert);
> > -     intcert =3D l_pem_load_certificate(CERTDIR "cert-intca.pem",
> > -                                             &intcertlen);
> > +     intcert =3D l_pem_load_certificate(CERTDIR "cert-intca.pem");
> >       assert(intcert);
> > -     cert =3D l_pem_load_certificate(CERTDIR "cert-entity-int.pem",
> > -                                     &certlen);
> > +     cert =3D l_pem_load_certificate(CERTDIR "cert-entity-int.pem");
> >       assert(cert);
> >
> > -     cakey =3D l_key_new(L_KEY_RSA, cacert, cacertlen);
> > +     cakey =3D l_cert_get_pubkey(cacert);
> >       assert(cakey);
> > -     intkey =3D l_key_new(L_KEY_RSA, intcert, intcertlen);
> > +     intkey =3D l_cert_get_pubkey(intcert);
> >       assert(intkey);
> > -     key =3D l_key_new(L_KEY_RSA, cert, certlen);
> > +     key =3D l_cert_get_pubkey(cert);
> >       assert(key);
> >
> >       trust =3D l_keyring_new();
> > @@ -492,18 +484,15 @@ static void test_trust_chain(const void *data)
> >       l_key_free(cakey);
> >       l_key_free(intkey);
> >       l_key_free(key);
> > -     l_free(cacert);
> > -     l_free(intcert);
> > -     l_free(cert);
> > +     l_cert_free(cacert);
> > +     l_cert_free(intcert);
> > +     l_cert_free(cert);
> > }
> >
> > static void test_key_crypto(const void *data)
> > {
> > -     uint8_t *cert;
> > -     size_t certlen;
> > -     uint8_t *pubcert;
> > -     size_t pubcertlen;
> > -     struct l_key *key;
> > +     struct l_key *privkey;
> > +     struct l_cert *cert;
> >       struct l_key *pubkey;
> >       bool is_public;
> >       size_t keybits;
> > @@ -514,24 +503,21 @@ static void test_key_crypto(const void *data)
> >       int hash =3D L_CHECKSUM_NONE;
> >       int rsa =3D L_KEY_RSA_PKCS1_V1_5;
> >
> > -     cert =3D l_pem_load_private_key(CERTDIR "cert-client-key-pkcs8.pe=
m",
> > -                                     NULL, NULL, &certlen);
> > +     privkey =3D l_pem_load_private_key(CERTDIR "cert-client-key-pkcs8=
.pem",
> > +                                             NULL, NULL);
> > +     assert(privkey);
> > +     cert =3D l_pem_load_certificate(CERTDIR "cert-client.pem");
> >       assert(cert);
> > -     pubcert =3D l_pem_load_certificate(CERTDIR "cert-client.pem",
> > -                                             &pubcertlen);
> > -     assert(pubcert);
> >
> > -     key =3D l_key_new(L_KEY_RSA, cert, certlen);
> > -     assert(key);
> > -     pubkey =3D l_key_new(L_KEY_RSA, pubcert, pubcertlen);
> > +     pubkey =3D l_cert_get_pubkey(cert);
> >       assert(pubkey);
> >
> > -     success =3D l_key_get_info(key, rsa, hash, &keybits, &is_public);
> > +     success =3D l_key_get_info(privkey, rsa, hash, &keybits, &is_publ=
ic);
> >       assert(success);
> >       assert(keybits =3D=3D 2048);
> >       assert(!is_public);
> >
> > -     success =3D l_key_get_info(key, rsa, L_CHECKSUM_NONE, &keybits,
> > +     success =3D l_key_get_info(privkey, rsa, L_CHECKSUM_NONE, &keybit=
s,
> >                                       &is_public);
> >       assert(success);
> >       assert(keybits =3D=3D 2048);
> > @@ -554,14 +540,14 @@ static void test_key_crypto(const void *data)
> >                               sizeof(ciphertext), sizeof(decrypted));
> >       assert(len < 0);
> >
> > -     len =3D l_key_decrypt(key, rsa, hash, ciphertext, decrypted,
> > +     len =3D l_key_decrypt(privkey, rsa, hash, ciphertext, decrypted,
> >                               sizeof(ciphertext), sizeof(decrypted));
> >       assert(len =3D=3D (ssize_t)strlen(plaintext));
> >       assert(strcmp(plaintext, (char *)decrypted) =3D=3D 0);
> >
> >       /* Decrypt reference ciphertext */
> >       memset(decrypted, 0, sizeof(decrypted));
> > -     len =3D l_key_decrypt(key, rsa, hash, reference_ciphertext, decry=
pted,
> > +     len =3D l_key_decrypt(privkey, rsa, hash, reference_ciphertext, d=
ecrypted,
> >                               sizeof(reference_ciphertext),
> >                               sizeof(decrypted));
> >       assert(len =3D=3D (ssize_t)strlen(plaintext));
> > @@ -571,7 +557,7 @@ static void test_key_crypto(const void *data)
> >       memset(decrypted, 0, sizeof(decrypted));
> >       memcpy(ciphertext, reference_ciphertext, sizeof(ciphertext));
> >       ciphertext[0] =3D ciphertext[0] ^ (uint8_t)0xFF;
> > -     len =3D l_key_decrypt(key, rsa, hash, ciphertext, decrypted,
> > +     len =3D l_key_decrypt(privkey, rsa, hash, ciphertext, decrypted,
> >                               sizeof(ciphertext),
> >                               sizeof(decrypted));
> >       assert(len < 0);
> > @@ -581,7 +567,7 @@ static void test_key_crypto(const void *data)
> >                               strlen(plaintext), sizeof(ciphertext));
> >       assert(len < 0);
> >
> > -     len =3D l_key_sign(key, rsa, hash, plaintext, ciphertext,
> > +     len =3D l_key_sign(privkey, rsa, hash, plaintext, ciphertext,
> >                               strlen(plaintext), sizeof(ciphertext));
> >       assert(len =3D=3D sizeof(ciphertext));
> >
> > @@ -589,7 +575,7 @@ static void test_key_crypto(const void *data)
> >                               strlen(plaintext), sizeof(ciphertext));
> >       assert(success);
> >
> > -     success =3D l_key_verify(key, rsa, hash, plaintext, ciphertext,
> > +     success =3D l_key_verify(privkey, rsa, hash, plaintext, ciphertex=
t,
> >                               strlen(plaintext), sizeof(ciphertext));
> >       assert(success);
> >
> > @@ -600,14 +586,13 @@ static void test_key_crypto(const void *data)
> >
> >       /* Corrupt signature */
> >       ciphertext[42] =3D ciphertext[52] ^ (uint8_t)0xFF;
> > -     success =3D l_key_verify(key, rsa, hash, plaintext, ciphertext,
> > +     success =3D l_key_verify(privkey, rsa, hash, plaintext, ciphertex=
t,
> >                               strlen(plaintext), sizeof(ciphertext));
> >       assert(!success);
> >
> > -     l_key_free(key);
> > +     l_key_free(privkey);
> >       l_key_free(pubkey);
> > -     l_free(cert);
> > -     l_free(pubcert);
> > +     l_cert_free(cert);
> > }
> >
> > int main(int argc, char *argv[])
> > diff --git a/unit/test-pem.c b/unit/test-pem.c
> > index 3325e54..b37a29e 100644
> > --- a/unit/test-pem.c
> > +++ b/unit/test-pem.c
> > @@ -91,36 +91,47 @@ static void test_encrypted_pkey(const void *data)
> > {
> >       const char *encrypted_pem =3D data;
> >       const char *plaintext_pem =3D CERTDIR "cert-client-key-pkcs8.pem";
> > -     bool encrypted;
> > -     size_t size1, size2;
> > -     uint8_t *pkey1, *pkey2;
> > +     bool is_encrypted;
> > +     size_t size;
> > +     uint8_t encrypted1[256], encrypted2[256], plaintext[256];
> > +     struct l_key *pkey1, *pkey2;
> > +     bool is_public;
> >
> > -     encrypted =3D false;
> > -     assert(!l_pem_load_private_key(encrypted_pem, NULL,
> > -                                     &encrypted, &size1));
> > -     assert(encrypted);
> > +     is_encrypted =3D false;
> > +     assert(!l_pem_load_private_key(encrypted_pem, NULL, &is_encrypted=
));
> > +     assert(is_encrypted);
> >
> > -     encrypted =3D false;
> > +     is_encrypted =3D false;
> >       assert(!l_pem_load_private_key(encrypted_pem, "wrong-passwd",
> > -                                     &encrypted, &size1));
> > -     assert(encrypted);
> > +                                     &is_encrypted));
> > +     assert(is_encrypted);
> >
> > -     encrypted =3D false;
> > -     pkey1 =3D l_pem_load_private_key(encrypted_pem, "abc",
> > -                                     &encrypted, &size1);
> > +     is_encrypted =3D false;
> > +     pkey1 =3D l_pem_load_private_key(encrypted_pem, "abc", &is_encryp=
ted);
> >       assert(pkey1);
>
> This assert is failing for me with a kernel that doesn't support RSA keys
> (v4.18.17). Could you add an l_key_is_supported() check like test-key.c to
> skip tests that depend on RSA key support for kernels that don't have the
> necessary feature?

Oh, right, I didn't realize this added a new requirement for this
test.  Thanks for testing.

Best regards

--===============5372603935175805995==--

