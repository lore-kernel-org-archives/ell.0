Content-Type: multipart/mixed; boundary="===============1878578999600405062=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 1/5] cert: Add cert.c for certificate types and routines
Date: Fri, 09 Nov 2018 00:22:27 +0100
Message-ID: <CAOq732J9TqrhKEw4qxtsjJ+9fSAHfF5FY3qHTZ9QtdQ==ri+Bg@mail.gmail.com>
In-Reply-To: <50c059aa-ed76-7d9f-bc2b-6762d7c81e11@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1878578999600405062==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Thu, 8 Nov 2018 at 18:39, Denis Kenzior <denkenz@gmail.com> wrote:
> On 11/08/2018 06:06 AM, Andrew Zaborowski wrote:
> > +struct l_cert {
> > +     struct l_cert *issuer;
> > +     struct l_cert *issued;
>
> So I don't really like this dual-purpose structure.  l_cert is used both
> as a standalone certificate and a certchain, and that creates weird
> situations where the caller isn't quite sure when l_cert_free should be
> called, especially when l_cert_link* is involved.  Not without looking
> at the implementation anyway, and that's undesirable from an API
> simplicity / nice-to-use perspective.

Yep, that's the downside of this approach, the up side is less code
for both the implementation and the user.  I'd understood you actually
preferred this approach but I'll happily switch to having separate
types.

>
> > +     enum l_cert_key_type pubkey_type;
> > +     size_t asn1_len;
> > +     uint8_t asn1[0];
> > +};
> > +
> > +static const struct pkcs1_encryption_oid {
> > +     enum l_cert_key_type key_type;
> > +     struct asn1_oid oid;
> > +} pkcs1_encryption_oids[] =3D {
> > +     { /* rsaEncryption */
> > +             L_CERT_KEY_RSA,
> > +             { 9, { 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x=
01 } },
> > +     },
> > +};
> > +
> > +static bool cert_set_pubkey_type(struct l_cert *cert)
> > +{
> > +     const uint8_t *key_type;
> > +     size_t key_type_len;
> > +     int i;
> > +
> > +     key_type =3D asn1_der_find_elem_by_path(cert->asn1, cert->asn1_le=
n,
> > +                                             ASN1_ID_OID, &key_type_le=
n,
> > +                                             X509_CERTIFICATE_POS,
> > +                                             X509_TBSCERTIFICATE_POS,
> > +                                             X509_TBSCERT_SUBJECT_KEY_=
POS,
> > +                                             X509_SUBJECT_KEY_ALGORITH=
M_POS,
> > +                                             X509_ALGORITHM_ID_ALGORIT=
HM_POS,
> > +                                             -1);
> > +     if (!key_type)
> > +             return false;
> > +
> > +     for (i =3D 0; i < (int) L_ARRAY_SIZE(pkcs1_encryption_oids); i++)
> > +             if (asn1_oid_eq(&pkcs1_encryption_oids[i].oid,
> > +                                     key_type_len, key_type))
> > +                     break;
>
> So the intent of l_cert is to only store public keys, right?  Not
> private keys.

Well, yes, the intent is to store the certificates which among other
things contain the subject's public key and do not contain a private
key.

>
> > +
> > +     if (i =3D=3D L_ARRAY_SIZE(pkcs1_encryption_oids))
> > +             cert->pubkey_type =3D L_CERT_KEY_UNKNOWN;
> > +     else
> > +             cert->pubkey_type =3D pkcs1_encryption_oids[i].key_type;
>
> It is unclear to me how you're making sure pubkey_type enumeration
> actually matches up to key_type.  There's no initializer on the enum, so
> the compiler can be free to choose anything?

Sorry, I don't understand what you mean here.  The left side of the
'=3D' is of the same type as the right side.  The right side will always
be L_CERT_KEY_RSA for now.

>
> > +
> > +     return true;
> > +}
> > +
> > +LIB_EXPORT struct l_cert *l_cert_new_from_der(const uint8_t *buf,
> > +                                             size_t buf_len)
> > +{
> > +     const uint8_t *seq =3D buf;
> > +     size_t seq_len =3D buf_len;
> > +     size_t content_len;
> > +     struct l_cert *cert;
> > +
> > +     /* Sanity check: outer element is a SEQUENCE */
> > +     if (seq_len-- < 1 || *seq++ !=3D ASN1_ID_SEQUENCE)
> > +             return NULL;
> > +
> > +     /* Sanity check: the SEQUENCE spans the whole buffer */
> > +     content_len =3D asn1_parse_definite_length(&seq, &seq_len);
>
> Is it me, or is asn1_parse_definite_length not doing proper boundary
> checking?  For example, if buf_len is 1, then doesn't this blow up?

My bad, I think asn1_parse_definite_length intially was initially in a
.c file with a limited number of callers all of which had length
checks so there was no point repeating the check there, I'll fix that.

>
> > +     if (content_len < 64 || content_len !=3D seq_len)
> > +             return NULL;
> > +
> > +     /*
> > +      * We could require the signature algorithm and the key algorithm
> > +      * to be one of our supported types here but instead we only
> > +      * require that when the user wants to verify this certificate or
> > +      * get the public key respectively.
> > +      */
> > +
> > +     cert =3D l_malloc(sizeof(struct l_cert) + buf_len);
> > +     cert->issuer =3D NULL;
> > +     cert->issued =3D NULL;
> > +     cert->asn1_len =3D buf_len;
> > +     memcpy(cert->asn1, buf, buf_len);
> > +
> > +     /* Sanity check: structure is correct up to the Public Key Algori=
thm */
> > +     if (!cert_set_pubkey_type(cert)) {
> > +             l_free(cert);
> > +             return NULL;
> > +     }
> > +
> > +     return cert;
> > +}
> > +
> > +LIB_EXPORT void l_cert_free(struct l_cert *cert)
> > +{
> > +     while (cert) {
> > +             struct l_cert *next =3D cert->issuer;
> > +
> > +             l_free(cert);
> > +             cert =3D next;
> > +     }
> > +}
> > +
> > +LIB_EXPORT bool l_cert_link_issuer(struct l_cert *cert, struct l_cert =
*issuer)
> > +{
> > +     if (!cert)
> > +             return false;
> > +
> > +     if (issuer && (issuer->issued || cert->issuer))
> > +             return false;
> > +
> > +     if (cert->issuer)
> > +             cert->issuer->issued =3D NULL;
> > +
> > +     cert->issuer =3D issuer;
> > +     return true;
> > +}
>
> So it is completely unclear to the caller that l_cert_link_issuer takes
> ownership of cert.  The caller can mistakenly call l_cert_free on the
> original cert and get a fun result...

Yep, that's why I mentioned refcounting in a conversation we had.
I'll change to using a separate type for certificate chains so this
will go away.

(Although, with the shape of a lot of ell API you probably wouldn't be
assuming anything about l_cert_link_issuer without checking the code.
I'll make sure to add doxygen comments to the next iteration of
cert.c)

>
> > +
> > +LIB_EXPORT struct l_cert *l_cert_get_issuer(struct l_cert *cert)
> > +{
> > +     return cert->issuer;
> > +}
> > +
> > +LIB_EXPORT const uint8_t *l_cert_get_der_data(struct l_cert *cert,
> > +                                             size_t *out_len)
> > +{
> > +     *out_len =3D cert->asn1_len;
> > +     return cert->asn1;
> > +}
>
> Personally I would just do something like:
>
> struct l_cert {
>         enum l_cert_key_type pubkey_type;
>         size_t asn1_len;
>         uint8_t asn1[0];
> };
>
> struct certchain_link {
>         struct l_cert cert;
>         struct certchain_link *issuer;
>         struct certchain_link *child;
> };
>
> struct l_certchain {
>         struct certchain_link *root;
>         struct certchain_link *key;
> };
>
> and consider dropping link_issuer completely.  Just build a certchain
> from the raw data directly, perhaps as a private constructor for now.

Could also just do:

struct l_certchain {
        struct l_queue *certs;
};

for simplicity.  We only have one use case for iterating from root to
leaf so we can reverse the queue at that time.  We maybe simply want
two public methods, l_certchain_foreach_from_root and
l_certchain_foreach_from_leaf.

As for the constructor we already need to parse two different "raw"
formats both of which are defined in pretty distant specs so I don't
think cert.c should know them, I'd rather have a l_certchain_link_cert
or similar.

>
> > +
> > +LIB_EXPORT bool l_cert_find_certchain(struct l_cert *cert,
> > +                                     struct l_cert *ca_cert)
> > +{
> > +     return true;
> > +}
> > +
> > +static void cert_key_cleanup(struct l_key **p)
> > +{
> > +     l_key_free_norevoke(*p);
> > +}
> > +
> > +static bool cert_verify_with_keyring(struct l_cert *cert,
> > +                                     struct l_keyring *ring,
> > +                                     struct l_cert *root,
> > +                                     struct l_keyring *trusted)
> > +{
> > +     if (!cert)
> > +             return true;
> > +
> > +     if (cert->pubkey_type !=3D L_CERT_KEY_RSA)
> > +             return false;
> > +
> > +     /*
> > +      * RFC5246 7.4.2:
> > +      * "Because certificate validation requires that root keys be
> > +      * distributed independently, the self-signed certificate that
> > +      * specifies the root certificate authority MAY be omitted from
> > +      * the chain, under the assumption that the remote end must
> > +      * already possess it in order to validate it in any case."
> > +      */
> > +     if (!cert->issuer && root && cert->asn1_len =3D=3D root->asn1_len=
 &&
> > +                     !memcmp(cert->asn1, root->asn1, root->asn1_len))
> > +             return true;
> > +
> > +     if (cert_verify_with_keyring(cert->issuer, ring, root, trusted)) {
> > +             L_AUTO_CLEANUP_VAR(struct l_key *, key, cert_key_cleanup);
> > +
> > +             key =3D l_key_new(L_KEY_RSA, cert->asn1, cert->asn1_len);
> > +             if (!key)
> > +                     return false;
> > +
> > +             if (!l_keyring_link(ring, key))
> > +                     return false;
> > +
> > +             if (trusted || cert->issuer)
> > +                     return true;
> > +
> > +             /*
> > +              * If execution reaches this point, it's known that:
> > +              *  * No trusted root key was supplied, so the chain is o=
nly
> > +              *    being checked against its own root
> > +              *  * The keyring 'ring' is not restricted yet
> > +              *  * The chain's root cert was just linked in to the
> > +              *    previously empty keyring 'ring'.
> > +              *
> > +              * By restricting 'ring' now, the rest of the certs in
> > +              * the chain will have their signature validated using 'k=
ey'
> > +              * as the root.
> > +              */
> > +             return l_keyring_restrict(ring, L_KEYRING_RESTRICT_ASYM_C=
HAIN,
> > +                                             trusted);
> > +     }
> > +
> > +     return false;
>
> So we're still doing the recursive verify.  It might makes things
> clearer if you added l_cert* stub classes first.  Then a separate commit
> moving the recursive implementation from tls.c to cert.c.

Ugh, that would be a commit for each method being moved?  There isn't
really much to review if we're just moving the code, however not
breaking TLS between the multiple commits could be really complicated.

Best regards

--===============1878578999600405062==--

